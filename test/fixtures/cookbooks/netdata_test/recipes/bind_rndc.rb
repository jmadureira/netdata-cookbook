netdata_bind_rndc_conf 'default_bind_rndc_config' do
  named_stats_path node['netdata']['plugins']['python']['bind_rndc']['config']['named_stats_path']
end
