NetData Cookbook
================

[![Build Status](https://travis-ci.org/sergiopena/netdata-cookbook.svg?branch=master)](https://travis-ci.org/sergiopena/netdata-cookbook)
[![NetData Cookbook](http://img.shields.io/badge/cookbook-v0.1.9-blue.svg?style=flat)](https://supermarket.chef.io/cookbooks/netdata)
[![Chef Version](http://img.shields.io/badge/chef-v12.9.38-orange.svg?style=flat)](https://www.chef.io)

This cookbook provides a way to download and install NetData from FireHol, a real-time performance monitoring.

Live demo: http://netdata.firehol.org

Github: https://github.com/firehol/netdata

Requirements
------------

### Platforms

- Centos => 6.7
- Ubuntu > 14.04

### Chef

- Chef 12.0 or later

### Cookbooks

- `yum-epel` = 0.7.0

Recipes
-------

### netdata::default

This would install NetData on supported platforms. At the moment this product does not have any distribution packages and the only supported installation method is to compile sources.

NetData cookbook will install required dependencies and after compilation succeeds those deps will be removed, except those packages that already were installed on the server prior to chef run.

## Usage

### netdata::default

Just include `netdata` in your node's `run_list`

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[netdata]"
  ]
}
```

## Attributes

- `node['netdata']['source']['git_repository']` - Netdata git repository. Defaults to https://github.com/firehol/netdata.git
- `node['netdata']['source']['git_revision']` - Netdata repository git reference. Can be a tag, branch or master. Defaults to master.
- `node['netdata']['source']['directory']` - Local directory where the netdata repo will be cloned. Defaults to /tmp/netdata but should be replaced because most UNIX system periodically clean the /tmp directory.

- `node['netdata']['plugins']['python']['mysql']['enabled']` - False by default. If set to true installs all needed python dependencies to connect to MySQL.

## Resources

### netdata_nginx_conf

Configures the netdata python nginx configuration.

```ruby
jobs_config = {
  'localhost' => {
    'name' => 'local',
    'url' => 'http://localhost/stub_status'
  },
  'localipv4' => {
    'name' => 'local',
    'url' => 'http://127.0.0.1/stub_status'
  }
}
netdata_nginx_conf 'default_config' do
  jobs jobs_config
end
```

To test using `ChefSpec` you can use the provided matcher `configure_netdata_nginx_module`.

```ruby
it 'does something' do
  expect(chef_run.converge(described_recipe)).to configure_netdata_nginx_module('some_config')
end
```

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
