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
# @param mins The amount of minutes for the source to be refreshed.
#        Can also be math: mins => '"$[24*60]"'
# @param aggregation Some source do not keep a backlog. Specify if ipsets
#        has to do this. For example to get a backlog for 7d and 30d aggregation => '"$[24*60*7] $[24*60*30]"'
# @param keep specify what to keep, either the ips or only the networks.
# @param url the url to download the ip_list
# @param processor Firehol has a list of processors. See https://github.com/firehol/blocklist-ipsets/wiki/Extending-update-ipsets
# @param category Specify the category of how the ip_list should be displayed. See
#        https://github.com/firehol/blocklist-ipsets/wiki/Extending-update-ipsets for then full list
# @param info A brief description of the source.
# @param maintainer The maintainer of the source.
# @param maintainer_url The url to the maintainers website.
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
