# This class configures ipsets
#
# @summary Class used to configure ipsets, should not be called directly.
#
class ipsets::config {
  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  # Split up the cron
  $cron_split = split($ipsets::cron, ' ')

  # Create user, group and the ipsets inside the users directory.
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

  # This directory does not exist when running as root
  if $ipsets::user != 'root' {
    file {'.update-ipsets dir':
      ensure => directory,
      path   => $ipsets::config_path,
      owner  => $ipsets::user,
      group  => $ipsets::group,
      before => File['update-ipsets config'],
    }
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
    path    => "${ipsets::config_path}/update-ipsets.conf",
    owner   => $ipsets::user,
    group   => $ipsets::group,
    content => epp('ipsets/update-ipsets.conf.epp'),
    require => File['ipsets in user'],
  }

  # This is the main cron, the '-l' is important in case you use a proxy
  # Use profile.d scripts to configure the http_proxy environment variable.
  -> cron { 'update-ipsets':
    command  => '/bin/bash -l -exec "update-ipsets > /dev/null 2>&1"',
    user     => $ipsets::user,
    minute   => $cron_split[0],
    hour     => $cron_split[1],
    monthday => $cron_split[2],
    month    => $cron_split[3],
    weekday  => $cron_split[4],
  }

  # This enables the self written export feature.
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

  # This code block enables the webserver. It might be beter to configure the
  # webserver yourself (for example for beter SSLCiphers)
  if $ipsets::manage_webserver {
    file {'ipsets webroot':
      ensure  => directory,
      path    => $ipsets::webroot,
      owner   => $ipsets::user,
      group   => 'root',
      require => User[$ipsets::user],
    }

    # The update script does not generate the index html, so remember to copy it.
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
