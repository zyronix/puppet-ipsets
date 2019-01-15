require 'spec_helper'

describe 'ipsets' do
  on_supported_os.each do |os, os_facts|
    context "with export enabled on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          export_enable: true,
          webroot: '/var/www/root',
          user_home: '/root',
        }
      end

      it {
        is_expected.to compile
        is_expected.to contain_file('ipsets export').with(
          'ensure'  => 'file',
          'mode'    => '0755',
          'path'    => '/root/export_ipsets.sh',
          'content' => %r{EXPORT_FILE_NAME=/var/www/root/ipsets.tar\nEXCLUDE_FILE=/root/exclude-list\nHOME_DIR=/root\n},
          'owner'   => 'ipsets',
          'group'   => 'ipsets',
        ).that_requires('File[ipsets in user]')
        is_expected.to contain_cron('export-ipsets').with(
          'command' => '/root/export_ipsets.sh',
          'user'    => 'ipsets',
          'minute'  => '*/9',
        )
      }
    end

    context "with webserver disabled on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          manage_webserver: false,
        }
      end

      it {
        is_expected.to compile
        is_expected.not_to contain_class('apache')
        is_expected.not_to contain_exec('copy index.html')
        is_expected.not_to contain_apache__vhost('ipsets')
        is_expected.not_to contain_file('ipsets webroot')
      }
    end

    context "webroot set #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          webroot: '/var/webroot',
        }
      end

      it {
        is_expected.to compile

        is_expected.to contain_file('ipsets webroot').with(
          'path' => '/var/webroot',
        )
        is_expected.to contain_exec('copy index.html').with(
          'command' => 'cp /usr/share/update-ipsets/webdir/index.html /var/webroot',
          'creates' => '/var/webroot/index.html',
        )
        is_expected.to contain_apache__vhost('ipsets-ssl').with(
          'docroot' => '/var/webroot',
        )
      }
    end
    context "changed vhost settings on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          ssl_cert: '/etc/ssl/ssl_cert.pem',
          ssl_key: '/etc/ssl/ssl_key.key',
          servername: 'SERVERNAME',
        }
      end

      it {
        is_expected.to compile

        is_expected.to contain_apache__vhost('ipsets-ssl').with(
          'servername' => 'SERVERNAME',
          'ssl_cert'   => '/etc/ssl/ssl_cert.pem',
          'ssl_key'    => '/etc/ssl/ssl_key.key',
        )
        is_expected.to contain_apache__vhost('ipsets').with(
          'servername'    => 'SERVERNAME',
          'redirect_dest' => 'https://SERVERNAME',
        )
      }
    end
    context "ssl disabled on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          ssl_enable: false,
        }
      end

      it {
        is_expected.to compile

        is_expected.not_to contain_apache__vhost('ipsets-ssl')
        is_expected.to contain_apache__vhost('ipsets')
      }
    end
    context "ssl disabled on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          firehol_downloadurl: 'http://example.com/firehol.zip',
          iprange_downloadurl: 'http://example.com/iprange.zip',
        }
      end

      it {
        is_expected.to compile

        is_expected.to contain_archive('firehol').with(
          'source' => 'http://example.com/firehol.zip',
        )
        is_expected.to contain_archive('iprange').with(
          'source' => 'http://example.com/iprange.zip',
        )
      }
    end
    context "changing user, group and homedir on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          user: 'user',
          user_home: '/user',
          group: 'group',
        }
      end

      it {
        is_expected.to compile

        is_expected.to contain_file('ipsets symlink').with(
          'path'   => '/usr/bin/update-ipsets',
          'target' => '/usr/sbin/update-ipsets',
        )
        is_expected.to contain_group('group')
        is_expected.to contain_user('user').with(
          'gid'        => 'group',
          'managehome' => true,
          'home'       => '/user',
        )
        is_expected.to contain_file('ipsets in user').with(
          'path'  => '/user/ipsets',
          'owner' => 'user',
          'group' => 'group',
        )
        is_expected.to contain_file('.update-ipsets dir').with(
          'path'  => '/user/.update-ipsets',
          'owner' => 'user',
          'group' => 'group',
        )
        is_expected.to contain_file('ipsets.d dir').with(
          'path'  => '/user/.update-ipsets/ipsets.d',
          'owner' => 'user',
          'group' => 'group',
        )
        is_expected.to contain_file('update-ipsets config').with(
          'path'  => '/user/.update-ipsets/update-ipsets.conf',
          'owner' => 'user',
          'group' => 'group',
          'content' => %r{^BASE_DIR=/user/ipsets\nHISTORY_DIR=/user/ipsets/history\nERRORS_DIR=/user/ipsets/errors\nWEB_DIR=/var/www/ipsets},
        )
        is_expected.to contain_cron('update-ipsets').with(
          'user' => 'user',
        )
        is_expected.to contain_file('ipsets webroot').with(
          'owner' => 'user',
        )
      }
    end
  end
end
