# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ipsets
#
# @param export_enable When enabled a cron job will be created that exports the ipsets to the export path.
# @param export_file_name Absolute path to the export tar.
# @param export_exclude_file Use this value to specify the fail containing the sources to be excluded during export.
#
class ipsets  (
  Boolean $export_enable = $ipsets::params::export_enable,
  String $export_file_name = $ipsets::params::export_file_name,
  String $export_exclude_file = $ipsets::params::export_exclude_file,
  Boolean $manage_webserver = $ipsets::params::manage_webserver,
) inherits ipsets::params {
  class {'ipsets::install': }
  -> class {'ipsets::config': }
}
