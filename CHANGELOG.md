# netdata CHANGELOG

This file is used to list changes made in each version of the netdata cookbook.

## 0.1.0
- Sergio Pena - Initial release of netdata

## 0.1.1
- Sergio Pena - Add tests and kitchen specs

## 0.1.2
- Sergio Pena - Add Ubuntu deps and tests.

## 0.1.4
- João Madureira - Do not run install if there are no changes in git repo

## 0.2.0
- Nick Willever - Change install to a resource
                - Create new generic resource for all python.d plugins
                - Deprecated netdata_bind_rndc_conf resource
                - Deprecated netdata_nginx_conf resource
                - Deprecate use of attributes
                - Deprecate use of default and install_netdata recipes
                - Convert to inspec for test-kitchen verifier framework

## 0.3.0
- Serge A. Salamanka - add update property
                     - add netdata_stream resource

## 0.3.1
- Serge A. Salamanka - use cookbook dependencies with all tested major version numbers

## 0.4.0
- João Madureira - Support for statsd plugin configuration
- Serge A. Salamanka - Support for binary installation

- - -
