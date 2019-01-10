require 'spec_helper'

describe 'ipsets::export_exclude' do
  let(:title) { 'iblocklist_edu*' }
  let(:pre_condition) { 'class {"ipsets": }' }
  let(:params) do
    {
      description: 'TEST NETWORKS',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile
        is_expected.to contain_concat__fragment('ipsets export exclude iblocklist_edu*').with(
          'target'  => 'ipsets export exclude',
          'content' => %r{'# TEST NETWORKS\niblocklist_edu\*\n'},
        )
      }
    end
  end
end
