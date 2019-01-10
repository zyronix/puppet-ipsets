require 'spec_helper'

describe 'ipsets' do
  on_supported_os.each do |os, os_facts|
    context "with export enabled on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          export_enable: true,
          export_file_name: '/root/EXPORT_FILE_NAME',
          export_exclude_file: '/root/EXPORT_EXCLUDE_FILE',
        }
      end

      it {
        is_expected.to compile
        is_expected.to contain_file('ipsets export').with(
          'ensure'  => 'file',
          'mode'    => '0755',
          'path'    => '/home/ipsets/export_ipsets.sh',
          'content' => %r{'EXPORT_FILE_NAME=/root/EXPORT_FILE_NAME\nEXCLUDE_FILE=/root/EXPORT_EXCLUDE_FILE\nHOME_DIR=/home/ipsets\n'},
          'owner'   => 'ipsets',
          'group'   => 'ipsets',
        ).that_requires('File[ipsets in user]')
        is_expected.to contain_cron('export-ipsets').with(
          'command' => '/home/ipsets/export_ipsets.sh',
          'user'    => 'ipsets',
          'minute'  => '*/9',
        )
      }
    end
  end
end
