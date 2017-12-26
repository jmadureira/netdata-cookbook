# NetData Cookbook

[![Build Status](https://travis-ci.org/jmadureira/netdata-cookbook.svg?branch=master)](https://travis-ci.org/jmadureira/netdata-cookbook)
[![NetData Cookbook](http://img.shields.io/badge/cookbook-v0.2.0-blue.svg?style=flat)](https://supermarket.chef.io/cookbooks/netdata)
[![Chef Version](http://img.shields.io/badge/chef-v12.9.38-orange.svg?style=flat)](https://www.chef.io)

This cookbook provides a way to download, install and configure NetData
from FireHol, a real-time performance monitoring.

Live demo: http://netdata.firehol.org

Github: https://github.com/firehol/netdata

## Requirements

### Platforms

- Amazon Linux 2013.09+
- Centos 6.7+
- Debian 7.11+
- Fedora 25+
- Ubuntu 14.04+

### Chef

- Chef 12.5+

### Cookbooks

- yum-epel
- apt

## Usage

This cookbook implements resources to install NetData and manage its
configuration files.

## Recipies

### default

Installs NetData using the netdata_install resource with default parameters.

### install_netdata

Deprecated, please use default recipe or netdata_install resource.

## Resources

### netdata_install

Installs NetData from source on supported platforms.

```rb
netdata_install 'default' do
  git_repository 'https://github.com/firehol/netdata.git'
  git_revision 'master'
  git_source_directory '/tmp/netdata'
  autoupdate true
  update true
end
```

- `git_repository` - Location of git repository to pull the NetData source.
- `git_revision` - Tag/Branch/Commit to checkout.
- `git_source_directory` - Location to sync the repository to on the server.
- `install_path` - Change the location where NetData is installed.
- `autoupdate` - Allow NetData to autoupdate itself via a cron entry.
- `update` - Allow chef-client to update NetData if it is already installed.

It's highly recommended to use a different path than `/tmp/netdata` for `git_source_directory` and in future versions the default path will change. This is encouraged because when `autoupdate` is set to true NetData will create a symbolic link from the source directory to cron.d and you don't want NetData to create a symbolic link to anything in `/tmp`

### netdata_config

Manages the main netdata.conf file. Call this as many times as needed.
Each name should be unique. (i.e. web, global)

```rb
netdata_config 'web' do
  owner 'netdata'
  group 'netdata'
  base_directory '/etc'
  configurations(
    'bind to' => 'localhost'
  )
end
```

Resulting file content (/etc/netdata/netdata.conf):

```sh
[web]
  bind to = localhost
```

- `owner` - User to own the file
- `group` - Group to own the file
- `base_directory` - Parent folder that holds the NetData configuration files.
- `configurations` - Hash of key, value pairs for customizing NetData.

This resource will restart the NetData service automatically.

### netdata_stream

Manages stream.conf file. Call this as many times as needed.  
Resource names could be either 'stream' or "#{api_key}" and "#{machine_guid}" depending on whether you configure slave or master NetData.
Name 'stream' should be used only once to configure slave NetData.
Values for api_key and machine_guid should be unique.

```rb
netdata_stream 'stream' do
  owner 'netdata'
  group 'netdata'
  base_directory "#{install_path}/netdata"
  configurations(
    'enabled' => 'yes',
    'destination' => 'netdata_master:19999',
    'api key' => '11111111-2222-3333-4444-555555555555'
  )
end
```

Resulting file content ("#{install_path}/netdata/etc/netdata/stream.conf"):

```sh
[stream]
  enabled = yes
  destination = netdata_master:19999
  api key = 11111111-2222-3333-4444-555555555555
```

- `owner` - User to own the file
- `group` - Group to own the file
- `base_directory` - Parent folder where the NetData has been installed to (should be "#{install_path}/netdata" if `install_path` was used in netdata_install resource, otherwise should not be used).
- `configurations` - Hash of key, value pairs for customizing NetData stream configuration.

This resource will restart the NetData service automatically.

### netdata_python_plugin

Manages python plugin configuration files.

```rb
netdata_python_plugin 'mysql' do
  owner 'netdata'
  group 'netdata'
  base_directory '/etc'
  global_configuration(
    'retries' => 5
  )
  jobs(
    'tcp' => {
      'name' => 'local',
      'host' => 'localhost',
      'port' => 3306   
    }
  )
end
```

Resulting file content (/etc/netdata/python.d/mysql.conf):

```sh
# GLOBAL
retries: 5

# JOBS
tcp:
  name: local
  host: localhost
  port: 3306
```

- `owner` - User to own the file
- `group` - Group to own the file
- `base_directory` - Parent folder that holds the NetData configuration files.
- `global_configuration` - Hash of global variables for the plugin.
- `jobs` - Hash of jobs that tell NetData to pull statistics from.

This resource will restart the NetData service automatically.

### netdata_bind_rndc_conf

Deprecated, please use netdata_python_plugin

### netdata_nginx_conf

Deprecated, please use netdata_python_plugin

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors:
* Sergio Pena https://github.com/sergiopena
* João Madureira https://github.com/jmadureira
* Nick Willever https://github.com/nictrix
