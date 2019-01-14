# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ipsets::config
class ipsets::config {
  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  group {$ipsets::group:
    ensure => present,
  }
  -> user {$ipsets::user:
    ensure     => present,
    managehome => true,
    gid        => $ipsets::group,
    home       => $ipsets::user_home,
    shell      => '/bin/bash',
  }
  -> file {'ipsets in user':
    ensure => directory,
    path   => "${ipsets::user_home}/ipsets",
    owner  => $ipsets::user,
    group  => $ipsets::group,
  }

  if $ipsets::user != 'root' {
    $config_path = "${ipsets::user_home}/.update-ipsets"

    file {'.update-ipsets dir':
      ensure => directory,
      path   => $config_path,
      owner  => $ipsets::user,
      group  => $ipsets::group,
      before => File['update-ipsets config'],
    }
  } else {
    $config_path = '/etc/firehol'
  }
  file {'ipsets.d dir':
    ensure  => directory,
    path    => $ipsets::ip_list_path,
    owner   => $ipsets::user,
    group   => $ipsets::group,
    require => File['update-ipsets config']
  }

  file {'update-ipsets config':
    ensure  => file,
    path    => "${config_path}/update-ipsets.conf",
    owner   => $ipsets::user,
    group   => $ipsets::group,
    content => epp('ipsets/update-ipsets.conf.epp'),
    require => File['ipsets in user'],
  }

  -> cron { 'update-ipsets':
    command => '/bin/bash -l -exec "update-ipsets > /dev/null 2>&1"',
    user    => $ipsets::user,
    minute  => '*/9',
  }

  if $ipsets::export_enable == true {
    file {'ipsets export':
      ensure  => file,
      mode    => '0755',
      path    => "${ipsets::user_home}/export_ipsets.sh",
      content => epp('ipsets/export.sh.epp'),
      owner   => $ipsets::user,
      group   => $ipsets::group,
      require => File['ipsets in user'],
    }
    concat { 'ipsets export exclude':
      path  => $ipsets::export_exclude_file,
      owner => $ipsets::user,
      group => $ipsets::group,
    }
    concat::fragment{ 'ipsets export exclude header':
      target  => 'ipsets export exclude',
      content => "#!/bin/bash\n# Managed by Puppet! DO NOT EDIT!\n",
      order   => '01'
    }
    cron { 'export-ipsets':
      command => "${ipsets::user_home}/export_ipsets.sh",
      user    => $ipsets::user,
      minute  => '*/9',
    }
  }
  if $ipsets::manage_webserver {
    file {'ipsets webroot':
      ensure  => directory,
      path    => $ipsets::webroot,
      owner   => $ipsets::user,
      group   => 'root',
      require => User[$ipsets::user],
    }

    exec {'copy index.html':
      command => "cp /usr/share/update-ipsets/webdir/index.html ${ipsets::webroot}",
      creates => "${ipsets::webroot}/index.html",
    }
    class{'apache::mod::dir': }
    if $ipsets::ssl_enable {
      apache::vhost { 'ipsets-ssl':
        servername     => $ipsets::servername,
        port           => '443',
        manage_docroot => false,
        docroot        => $ipsets::webroot,
        options        => ['-MultiViews'],
        directoryindex => 'index.html',
        ssl            => true,
        ssl_cert       => $ipsets::ssl_cert,
        ssl_key        => $ipsets::ssl_key,
      }
      apache::vhost { 'ipsets':
        servername      => $ipsets::servername,
        port            => '80',
        manage_docroot  => false,
        redirect_status => 'permanent',
        redirect_dest   => "https://${ipsets::servername}",
        docroot         => $ipsets::webroot,
        options         => ['-MultiViews'],
      }
    } else {
      apache::vhost { 'ipsets':
        servername     => $ipsets::servername,
        port           => '80',
        manage_docroot => false,
        docroot        => $ipsets::webroot,
        options        => ['-MultiViews'],
        directoryindex => 'index.html',
      }
    }
  }
}
