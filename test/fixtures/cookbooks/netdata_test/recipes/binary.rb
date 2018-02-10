netdata_install 'optional' do
  install_method 'binary'
end

# changes to comply with configuration for source package
link '/etc/netdata' do
  to '/opt/netdata/etc/netdata'
end

directory '/var/log/netdata' do
  owner 'netdata'
  group 'netdata'
  action :create
end

include_recipe 'netdata_test::configuration'
