name             'netdata'
maintainer       'Sergio Pena'
maintainer_email 'kekio.one@gmail.com'
license          'Apache-2.0'
description      'Compile, install and configure netdata'
version          '0.4.1'
source_url       'https://github.com/jmadureira/netdata-cookbook'
issues_url       'https://github.com/jmadureira/netdata-cookbook/issues'
chef_version     '>= 13.0'

depends 'yum-epel', '< 3.0.0'
depends 'apt', '< 7.0.0'

%w(debian ubuntu centos redhat oracle amazon fedora).each do |platform|
  supports platform
end
