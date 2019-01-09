# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ipsets::params
class ipsets::params {
  $manage_webserver = true

  $required_packages = [
    'unzip',
    'whois',
    'zlib1g-dev',
    'gcc',
    'make',
    'git',
    'autoconf',
    'autogen',
    'automake',
    'pkg-config',
    'curl',
    'ipset'
  ]

  $firehol_downloadurl = 'https://github.com/firehol/firehol/archive/master.zip'
  $iprange_downloadurl = 'https://github.com/firehol/iprange/archive/master.zip'

  $ipsets_user = 'ipsets'
  $ipsets_group = 'ipsets'

  $tmp_dir = '/tmp'
  $firehol_archive = 'firehol.zip'
  $iprange_archive = 'iprange.zip'

  $install_path = '/root'
  $firehol_install_path = "${install_path}/firehol-master"
  $iprange_install_path = "${install_path}/iprange-master"
}
