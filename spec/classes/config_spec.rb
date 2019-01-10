require 'spec_helper'

describe 'ipsets::config' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:pre_condition) { 'class {"ipsets": }' }
      let(:facts) { os_facts }

      it {
        is_expected.to compile
        is_expected.to contain_group('ipsets').that_comes_before('User[ipsets]')
        is_expected.to contain_user('ipsets').with(
          'managehome' => true,
          'gid'        => 'ipsets',
          'home'       => '/home/ipsets',
          'shell'      => '/bin/bash',
        ).that_comes_before('File[ipsets webroot]')
        is_expected.to contain_file('ipsets webroot').with(
          'ensure' => 'directory',
          'path'   => '/var/www/ipsets',
          'owner'  => 'ipsets',
          'group'  => 'root',
        ).that_comes_before('File[ipsets in user]')
        is_expected.to contain_file('ipsets in user').with(
          'ensure' => 'directory',
          'path'   => '/home/ipsets/ipsets',
          'owner'  => 'ipsets',
          'group'  => 'ipsets',
        )
        is_expected.to contain_file('.update-ipsets dir').with(
          'ensure' => 'directory',
          'path'   => '/home/ipsets/.update-ipsets',
          'owner'  => 'ipsets',
          'group'  => 'ipsets',
        ).that_comes_before('File[update-ipsets config]')
        is_expected.to contain_file('update-ipsets config').with(
          'ensure'  => 'file',
          'path'    => '/home/ipsets/.update-ipsets/update-ipsets.conf',
          'owner'   => 'ipsets',
          'group'   => 'ipsets',
          'content' => %r{'^BASE_DIR=/home/ipsets/ipsets\nHISTORY_DIR=/home/ipsets/ipsets/history\nERRORS_DIR=/home/ipsets/ipsets/errors\nWEB_DIR=/var/www/ipsets'},
        ).that_requires('File[ipsets in user]')
        is_expected.to contain_cron('update-ipsets').with(
          'command' => 'update-ipsets > /dev/null 2>&1',
          'user'    => 'ipsets',
          'minute'  => '*/9',
        ).that_requires('File[update-ipsets config]')
        is_expected.to contain_file('ipsets symlink').with(
          'ensure' => 'link',
          'path'   => '/usr/bin/update-ipsets',
          'target' => '/usr/sbin/update-ipsets',
        )
        is_expected.to contain_apache__vhost('ipsets-ssl').with(
          'port'           => '443',
          'manage_docroot' => false,
          'docroot'        => '/var/www/ipsets',
          'ssl'            => true,
          'ssl_cert'       => '/etc/ssl/certs/ssl-cert-snakeoil.pem',
          'ssl_key'        => '/etc/ssl/private/ssl-cert-snakeoil.key',
        )
        is_expected.to contain_apache__vhost('ipsets').with(
          'port'            => '80',
          'manage_docroot'  => false,
          'redirect_status' => 'permanent',
        )
        is_expected.to contain_class('apache::mod::dir')
        is_expected.to contain_exec('copy index.html').with(
          'command' => 'cp /usr/share/update-ipsets/webdir/index.html /var/www/ipsets',
          'creates' => '/var/www/ipsets/index.html',
        )
      }
    end
  end
end
