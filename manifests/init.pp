# Main class of this module which calls all other sub classes.
# This class must always be called before calling any other class or type.
#
# @summary Calling sub calls.
#
# @example
#   include ipsets
#
# @param export_enable When enabled a cron job will be created that exports the ipsets to the export path.
# @param manage_webserver Enabled by default. When enabled, this will run the apache module and create some vhosts.
# @param webroot Absoluth path towards the directory where the html files will be stored. Or where the export file will be placed.
# @param servername If the webserver is managed by this module, use this to set the servername. Default is fqdn.
# @param ssl_cert Use this to specify the path of the ssl_cert. Defaults to /etc/ssl/certs/ssl-cert-snakeoil.pem.
# @param ssl_key Use this to specify the path of the ssl_key. Defaults to /etc/ssl/private/ssl-cert-snakeoil.key.
# @param ssl_enable If the webserver is managed by this module this setting can be used to either enable or disable SSL.
#        By default this setting is set to true.
# @param firehol_downloadurl Specify the download location of the firehol source.
# @param iprange_downloadurl Specify the download location of the iprange source.
# @param user Specify as which user the application must run. Defaults to ipsets.
#        It is possible to run as root, but no recommanded. The user will be created by this module.
# @param user_home Specify the home directory of the user. Ipsets will place files in the homedirectory.
# @param group Specify the primary group of the user. Will be created. Defaults to ipsets.
# @param cron Specify the cron string in the format '* * * * *'. Defaults to every 9 minutes.
#
class ipsets  (
  Boolean $export_enable = $ipsets::params::export_enable,
  Boolean $manage_webserver = $ipsets::params::manage_webserver,
  Stdlib::Unixpath $webroot = $ipsets::params::webroot,
  String $servername = $ipsets::params::servername,
  Stdlib::Unixpath $ssl_cert = $ipsets::params::ssl_cert,
  Stdlib::Unixpath $ssl_key = $ipsets::params::ssl_key,
  Boolean $ssl_enable = $ipsets::params::ssl_enable,
  String $firehol_downloadurl = $ipsets::params::firehol_downloadurl,
  String $iprange_downloadurl = $ipsets::params::iprange_downloadurl,
  String $user = $ipsets::params::user,
  String $user_home = $ipsets::params::user_home,
  String $group = $ipsets::params::group,
  String $cron = $ipsets::params::cron,
) inherits ipsets::params {
  if user != 'root' {
    $config_path = "${user_home}/.update-ipsets"
    $ip_list_path = "${config_path}/ipsets.d"
  } else {
    $config_path = '/etc/firehol'
    $ip_list_path = "${config_path}/ipsets.d"
  }
  $export_exclude_file = "${user_home}/exclude-list"

  class {'ipsets::install': }
  -> class {'ipsets::config': }
}
