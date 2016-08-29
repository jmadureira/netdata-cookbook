NetData Cookbook
================

[![Build Status](https://travis-ci.org/sergiopena/netdata-cookbook.svg?branch=master)](https://travis-ci.org/sergiopena/netdata-cookbook)
[![NetData Cookbook](http://img.shields.io/badge/cookbook-v0.1.4-blue.svg?style=flat)](https://supermarket.chef.io/cookbooks/netdata)
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

This would install NetData on supported platforms. At the moment this product does not have any distribution packages and only supported installation method it to compile sources.

NetData cookbook will install required dependencies and after compilation succeedis those deps will be removed, except those packages that already were installed on the server prior to chef run.

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

## Contributing

1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

## License and Authors

Authors: Sergio Pena <sergio.pena@abiquo.com>

