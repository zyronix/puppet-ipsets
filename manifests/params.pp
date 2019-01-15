# Set all the parameters for the ipsets class
#
# @summary Sets parameters for the main ipsets class. Should not be called directly.
#
class ipsets::params {
  $manage_webserver = true
  $webroot = '/var/www/ipsets'
  $servername = $::fqdn
  $ssl_cert = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
  $ssl_key = '/etc/ssl/private/ssl-cert-snakeoil.key'
  $ssl_enable = true

  case $facts['osfamily'] {
    'Redhat': {
      $required_packages = [
        'unzip',
        'whois',
        'zlib-devel',
        'gcc',
        'make',
        'git',
        'autoconf',
        'autogen',
        'automake',
        'curl',
        'ipset',
        'traceroute'
      ]
    }
    'Debian': {
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
        'ipset',
        'traceroute'
      ]
    }
    default: { fail('OS family not supported') }
  }

  $firehol_downloadurl = 'https://github.com/firehol/firehol/archive/master.zip'
  $iprange_downloadurl = 'https://github.com/firehol/iprange/archive/master.zip'

  $user = 'ipsets'
  $user_home = '/home/ipsets'
  $group = 'ipsets'

  $export_enable = false

  # The parameter will probably not require setting by the user
  # If you however need them please open an issue.
  $tmp_dir = '/tmp'
  $firehol_archive = 'firehol.zip'
  $iprange_archive = 'iprange.zip'

  $install_path = '/root'
  $firehol_install_path = "${install_path}/firehol-master"
  $iprange_install_path = "${install_path}/iprange-master"

  $export_file_name = 'ipsets.tar'
}
