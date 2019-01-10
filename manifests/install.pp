# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ipsets::install
class ipsets::install {
  Exec {
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
  }

  package{$ipsets::required_packages:
    ensure => installed,
  }

  -> archive {'firehol':
    path         => "${ipsets::tmp_dir}/${ipsets::firehol_archive}",
    source       => $ipsets::firehol_downloadurl,
    extract      => true,
    extract_path => $ipsets::install_path,
    creates      => $ipsets::firehol_install_path,
    cleanup      => false,
    notify       => Exec['firehol autogen']
  }

  -> archive {'iprange':
    path         => "${ipsets::tmp_dir}/${ipsets::iprange_archive}",
    source       => $ipsets::iprange_downloadurl,
    extract      => true,
    extract_path => $ipsets::install_path,
    creates      => $ipsets::iprange_install_path,
    cleanup      => false,
    notify       => Exec['iprange autogen']
  }

  exec {'iprange autogen':
    command => "${ipsets::iprange_install_path}/autogen.sh",
    creates => '/usr/bin/iprange',
    cwd     => $ipsets::iprange_install_path,
  }
  ~> exec {'iprange configure':
    command     => "${ipsets::iprange_install_path}/configure --prefix=/usr CFLAGS=\"-march=native -O3\" --disable-man",
    creates     => '/usr/bin/iprange',
    cwd         => $ipsets::iprange_install_path,
    refreshonly => true,
  }
  ~> exec {'iprange make':
    command     => 'make',
    creates     => '/usr/bin/iprange',
    cwd         => $ipsets::iprange_install_path,
    refreshonly => true,
  }
  ~> exec {'iprange make install':
    command     => 'make install',
    creates     => '/usr/bin/iprange',
    cwd         => $ipsets::iprange_install_path,
    refreshonly => true,
  }

  exec {'firehol autogen':
    command => "${ipsets::firehol_install_path}/autogen.sh",
    creates => '/usr/sbin/firehol',
    cwd     => $ipsets::firehol_install_path,
  }
  ~> exec {'firehol configure':
    command     => "${ipsets::firehol_install_path}/configure --prefix=/usr --sysconfdir=/etc --disable-man --disable-doc",
    creates     => '/usr/sbin/firehol',
    cwd         => $ipsets::firehol_install_path,
    refreshonly => true,
  }
  ~> exec {'firehol make':
    command     => 'make',
    creates     => '/usr/sbin/firehol',
    cwd         => $ipsets::firehol_install_path,
    refreshonly => true,
  }
  ~> exec {'firehol make install':
    command     => 'make install',
    creates     => '/usr/sbin/firehol',
    cwd         => $ipsets::firehol_install_path,
    refreshonly => true,
  }

  if $ipsets::user != 'root' {
    file {'ipsets symlink':
      ensure  => link,
      path    => '/usr/bin/update-ipsets',
      target  => '/usr/sbin/update-ipsets',
      require => Exec['firehol make install']
    }
  }

  if $ipsets::manage_webserver {
    class {'apache':
      default_vhost => false,
      default_mods  => false,
    }
  }
}
