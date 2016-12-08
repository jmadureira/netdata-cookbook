netdata_nginx_conf 'default_config' do
  jobs node['netdata']['plugins']['python']['nginx']['config']
end
