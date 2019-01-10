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
        ).that_comes_before('Archive[iprange]').that_notifies('Exec[firehol autogen]')
        is_expected.to contain_archive('iprange').with(
          'path'         => '/tmp/iprange.zip',
          'source'       => 'https://github.com/firehol/iprange/archive/master.zip',
          'extract'      => true,
          'extract_path' => '/root',
          'creates'      => '/root/iprange-master',
          'cleanup'      => false,
        ).that_notifies('Exec[iprange autogen]')
        is_expected.to contain_exec('iprange autogen').with(
          'command'     => '/root/iprange-master/autogen.sh',
          'creates'     => '/usr/bin/iprange',
          'cwd'         => '/root/iprange-master',
        ).that_notifies('Exec[iprange configure]')
        is_expected.to contain_exec('iprange configure').with(
          'command'     => '/root/iprange-master/configure --prefix=/usr CFLAGS="-march=native -O3" --disable-man',
          'creates'     => '/usr/bin/iprange',
          'cwd'         => '/root/iprange-master',
          'refreshonly' => true,
        ).that_notifies('Exec[iprange make]')
        is_expected.to contain_exec('iprange make').with(
          'command'     => 'make',
          'creates'     => '/usr/bin/iprange',
          'cwd'         => '/root/iprange-master',
          'refreshonly' => true,
        ).that_notifies('Exec[iprange make install]')
        is_expected.to contain_exec('iprange make install').with(
          'command'     => 'make install',
          'creates'     => '/usr/bin/iprange',
          'cwd'         => '/root/iprange-master',
          'refreshonly' => true,
        )
        is_expected.to contain_exec('firehol autogen').with(
          'command'     => '/root/firehol-master/autogen.sh',
          'creates'     => '/usr/sbin/firehol',
          'cwd'         => '/root/firehol-master',
        ).that_notifies('Exec[firehol configure]')
        is_expected.to contain_exec('firehol configure').with(
          'command'     => '/root/firehol-master/configure --prefix=/usr --sysconfdir=/etc --disable-man --disable-doc',
          'creates'     => '/usr/sbin/firehol',
          'cwd'         => '/root/firehol-master',
          'refreshonly' => true,
        ).that_notifies('Exec[firehol make]')
        is_expected.to contain_exec('firehol make').with(
          'command'     => 'make',
          'creates'     => '/usr/sbin/firehol',
          'cwd'         => '/root/firehol-master',
          'refreshonly' => true,
        ).that_notifies('Exec[firehol make install]')
        is_expected.to contain_exec('firehol make install').with(
          'command'     => 'make install',
          'creates'     => '/usr/sbin/firehol',
          'cwd'         => '/root/firehol-master',
          'refreshonly' => true,
        )
        is_expected.to contain_file('ipsets symlink').with(
          'ensure' => 'link',
          'path'   => '/usr/bin/update-ipsets',
          'target' => '/usr/sbin/update-ipsets',
        ).that_requires('Exec[firehol make install]')
        is_expected.to contain_class('apache').with(
          'default_vhost' => false,
          'default_mods'  => false,
        )
      }
    end
  end
end
