require 'spec_helper'

describe 'ipsets::ip_list' do
  let(:title) { 'TEST_LIST' }
  let(:pre_condition) { 'class {"ipsets": }' }
  let(:params) do
    {
      mins: 5,
      aggregation: 0,
      keep: 'both',
      url: 'http://example.com/',
      processor: 'trim',
      category: 'malware',
      info: 'INFO',
      maintainer: 'TEST',
      maintainer_url: 'http://maintainer.example.com',
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it {
        is_expected.to compile

        is_expected.to contain_file('TEST_LIST ip_list').with(
          'path'    => '/home/ipsets/.update-ipsets/ipsets.d/TEST_LIST.conf',
          'owner'   => 'ipsets',
          'group'   => 'ipsets',
          'content' => %r{^update TEST_LIST 5 0 ipv4 both \\\n\s*"http:\/\/example\.com\/" \\\n\s*trim \\\n\s*"malware" \\\n\s*"INFO" \\\n\s*"TEST" "http:\/\/maintainer\.example\.com" \\\n$},
        )

        is_expected.to contain_exec('TEST_LIST enable ip_list').with(
          'command'     => 'update-ipsets enable TEST_LIST',
          'user'        => 'ipsets',
          'creates'     => '/home/ipsets/ipsets/TEST_LIST.source',
          'path'        => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          'cwd'         => '/home/ipsets',
          'group'       => 'ipsets',
          'environment' => ['HOME=/home/ipsets'],
        ).that_requires('File[TEST_LIST ip_list]')
      }
    end
  end
end
