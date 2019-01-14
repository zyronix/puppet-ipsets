# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ipsets::params
class ipsets::params {
  $manage_webserver = true
  $webroot = '/var/www/ipsets'
  $servername = $::fqdn
  $ssl_cert = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $ssl_key = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $ssl_enable = true

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

  $user = 'ipsets'
  $user_home = '/home/ipsets'
  $group = 'ipsets'

  $ip_list_path = "${user_home}/.update-ipsets/ipsets.d"

  $tmp_dir = '/tmp'
  $firehol_archive = 'firehol.zip'
  $iprange_archive = 'iprange.zip'

  $install_path = '/root'
  $firehol_install_path = "${install_path}/firehol-master"
  $iprange_install_path = "${install_path}/iprange-master"

  $export_enable = false
  $export_file_name = "${webroot}/ipsets.tar"
  $export_exclude_file = "${user_home}/exclude-list"
}
