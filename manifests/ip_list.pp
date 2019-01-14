# Add additional iplists to ipsets.
#
# @summary Add additional iplists to ipsets.
#
# @example
#   ipsets::ip_list { 'dshield': 
#     mins           => 5,
#     aggregation    => 0,
#     keep           => 'both',
#     url            => 'https://www.dshield.org/block.txt',
#     processor      => trim,
#     category       => 'attack',
#     info           => 'Dshield blocklist',
#     maintainer     => 'Internet Storm Shield',
#     maintainer_url => 'https://www.dshield.org/',
#   }

define ipsets::ip_list(
  Variant[String, Integer] $mins,
  Variant[String, Integer] $aggregation,
  Ipsets::Ip_list::Keep $keep,
  Stdlib::Httpurl $url,
  String $processor,
  Ipsets::Ip_list::Category $category,
  String $info,
  String $maintainer,
  Stdlib::Httpurl $maintainer_url,
) {
  file {"${name} ip_list":
    path    => "${ipsets::ip_list_path}/${name}.conf",
    owner   => $ipsets::user,
    group   => $ipsets::group,
    content => epp('ipsets/ip_list.conf.epp', {
      'name'           => $name,
      'mins'           => $mins,
      'aggregation'    => $aggregation,
      'keep'           => $keep,
      'url'            => $url,
      'processor'      => $processor,
      'category'       => $category,
      'info'           => $info,
      'maintainer'     => $maintainer,
      'maintainer_url' => $maintainer_url,
    }),
    require => Class['ipsets'],
  }
  exec {"${name} enable ip_list":
    command     => "update-ipsets enable ${name}",
    user        => $::ipsets::user,
    creates     => "${ipsets::user_home}/ipsets/${name}.source",
    path        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
    cwd         => $ipsets::user_home,
    group       => $ipsets::group,
    environment => ["HOME=${ipsets::user_home}"],
    require     => File["${name} ip_list"],
  }
}
