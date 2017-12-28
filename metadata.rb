name             'netdata'
maintainer       'Sergio Pena'
maintainer_email 'kekio.one@gmail.com'
license          'Apache-2.0'
description      'Compile, install and configure netdata'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '0.3.0'
source_url		   'https://github.com/jmadureira/netdata-cookbook'
issues_url		   'https://github.com/jmadureira/netdata-cookbook/issues'
chef_version     '>= 12.5' if respond_to?(:chef_version)

depends 'yum-epel'
depends 'apt'

%w(debian ubuntu centos redhat oracle amazon fedora).each do |platform|
  supports platform
end
