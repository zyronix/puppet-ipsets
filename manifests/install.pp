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
    command => './autogen.sh',
    creates => '/usr/sbin/iprange',
    cwd     => $ipsets::iprange_install_path,
  }
  ~> exec {'iprange configure':
    command     => './configure --prefix=/usr CFLAGS="-march=native -O3" --disable-man',
    creates     => '/usr/sbin/iprange',
    cwd         => $ipsets::iprange_install_path,
    refreshonly => true,
  }
  ~> exec {'iprange make':
    command     => 'make',
    creates     => '/usr/sbin/iprange',
    cwd         => $ipsets::iprange_install_path,
    refreshonly => true,
  }
  ~> exec {'iprange make install':
    command     => 'make install',
    creates     => '/usr/sbin/iprange',
    cwd         => $ipsets::iprange_install_path,
    refreshonly => true,
  }
}
