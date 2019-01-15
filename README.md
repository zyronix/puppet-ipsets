
# ipsets

#### Table of Contents

1. [Description](#description)
2. [Setup - The basics of getting started with ipsets](#setup)
    * [What ipsets affects](#what-ipsets-affects)
    * [Setup requirements](#setup-requirements)
    * [Beginning with ipsets](#beginning-with-ipsets)
3. [Usage - Configuration options and additional functionality](#usage)
4. [Limitations - OS compatibility, etc.](#limitations)
5. [Development - Guide for contributing to the module](#development)

## Description

This module installs IPSets, which is part of Firehol. IPsets is a script called: update-ipsets which download ipsets or blacklist on the internet. Those IPSets can be used to analyse logfile. For example during analyse of an attack it might be interested to compare IPs with IPs on black lists. Besides blacklists there are also IPsets of information sources. For example the IPs of Google. Using those IPs it becomes easier to analyse log files.

Basically it setup up a selfhosted: http://iplists.firehol.org/

This module helps you to install everything for this.

## Setup

### What ipsets affects

With the default settings it will install ipsets from source, run as the user ipsets and configures apache aswell.

### Setup Requirements

The only requirement that is there is if you enable SSL and let this module configure the webserver that SSL certicates are available. This is not the case for Redhat / CentOS.

Create self signed certificates using:

```
mkdir -p /etc/ssl/private
chmod 700 /etc/ssl/private
/etc/ssl/certs/make-dummy-cert /etc/ssl/private/cert.pem
chmod 600 /etc/ssl/private/cert.pem
```

Now configure ipsets to use the file:

```
class {'ipsets':
  ssl_cert => '/etc/ssl/private/cert.pem',
  ssl_key  => '/etc/ssl/private/cert.pem',
}
```

### Beginning with ipsets

To use ipsets just include ipsets:

```
include ipsets
```

Now everything should be setup, you still have to enable sources.

```
# login on the machine
su - ipsets
update-ipsets enable dshield
update-ipsets enable firehol_level1
update-ipsets -s
```

This is the minimal setup needed. The module has set up everything to update every 9 minutes.

A beter setup is to enable all sources:

```
# login on the machine
su - ipsets
update-ipsets --enable-all
```

This will take a lot of time and will cause a lot of resources (network and diskspace ~30GB)

## Usage

### More advanced
Some more of the advanced parameters. For example when you have enable all sources it might be beter to place all the data on a different disk. The only way to do this is to set the home directory of the user to the new disk. In our example '/data'.

```
class {'ipsets':
  user          => 'testuser',
  group         => 'testgroup',
  webroot       => '/var/www/here',
  user_home     => '/data',
}
```

### Export IPSets
When all the sources have been downloaded it might be handy to download all the sources at once. For this the export function is available, but this is disabled by default.

The export function export all the source every 9 minutes aswell and places them as a tar in the webroot folder.

```
class {'ipsets':
  export_enable => true,
}
```

In case you want to stop exporting a specify source, you can use the export_exclude defined_type. To disable dshield in the export:

```
ipsets::export_exclude { 'dshield*': 
  description => 'Reason why you want to exclude it',
}
```

### Adding additional ipsets
You might want to add additional ipsets, for this use the ip_list defined type:

```
ipsets::ip_list { 'dshield': 
  mins           => 5,
  aggregation    => 0,
  keep           => 'both',
  url            => 'https://www.dshield.org/block.txt',
  processor      => trim,
  category       => 'attack',
  info           => 'Dshield blocklist',
  maintainer     => 'Internet Storm Shield',
  maintainer_url => 'https://www.dshield.org/',
}
```

## Limitations

Not yet tested running under the root user.

## Development

This module uses PDK, so make sure all the unit test pass and validation pass. Make sure you written new tests for your code and if required any additional documentation. Also remember to generate new references.md file (using puppet strings generate --format markdown).
