# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include ipsets
class ipsets inherits ipsets::params {
  class {'ipsets::install': }
  -> class {'ipsets::config': }
}
