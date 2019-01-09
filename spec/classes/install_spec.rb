require 'spec_helper'

describe 'ipsets::install' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) { 'class {"ipsets": }' }
      let(:facts) { os_facts }

      it {
        is_expected.to compile
        is_expected.to contain_package('unzip').that_comes_before('Archive[firehol]')
        is_expected.to contain_archive('firehol').with(
          'path'         => '/tmp/firehol.zip',
          'source'       => 'https://github.com/firehol/firehol/archive/master.zip',
          'extract'      => true,
          'extract_path' => '/root',
          'creates'      => '/root/firehol-master',
          'cleanup'      => false,
        ).that_comes_before('Archive[iprange]')
        is_expected.to contain_archive('iprange').with(
          'path'         => '/tmp/iprange.zip',
          'source'       => 'https://github.com/firehol/iprange/archive/master.zip',
          'extract'      => true,
          'extract_path' => '/root',
          'creates'      => '/root/iprange-master',
          'cleanup'      => false,
        )
        is_expected.to contain_exec('iprange autogen').with(
          'command'     => './autogen.sh',
          'creates'     => '/usr/sbin/iprange',
          'cwd'         => '/root/iprange-master',
        ).that_notifies('Exec[iprange configure]')
        is_expected.to contain_exec('iprange configure').with(
          'command'     => './configure --prefix=/usr CFLAGS="-march=native -O3" --disable-man',
          'creates'     => '/usr/sbin/iprange',
          'cwd'         => '/root/iprange-master',
          'refreshonly' => true,
        ).that_notifies('Exec[iprange make]')
        is_expected.to contain_exec('iprange make').with(
          'command'     => 'make',
          'creates'     => '/usr/sbin/iprange',
          'cwd'         => '/root/iprange-master',
          'refreshonly' => true,
        ).that_notifies('Exec[iprange make install]')
        is_expected.to contain_exec('iprange make install').with(
          'command'     => 'make install',
          'creates'     => '/usr/sbin/iprange',
          'cwd'         => '/root/iprange-master',
          'refreshonly' => true,
        )
      }
    end
  end
end
