# Generates entries in the export concat
#
# @summary Add ipsets to be excluded for export
#
# @example
#   ipsets::export_exclude { 'iblocklist_edu*': 
#     description => 'Education networks',
#   }
# @param [String] description a description in the exclude file so it is clear why it is disabled
#
define ipsets::export_exclude(
  String $description
) {
    concat::fragment{ "ipsets export exclude ${name}":
      target  => 'ipsets export exclude',
      content => "# ${description}\n${name}\n",
      order   => '10'
    }
}
