netdata_config 'global' do
  configurations(
    'log directory' => '/var/log/netdata',
    'history' => 3996
  )
end

netdata_config 'web' do
  configurations(
    'bind to' => 'localhost'
  )
end

netdata_config 'plugin:proc:/proc/meminfo' do
  configurations(
    'committed memory' => 'yes',
    'writeback memory' => 'yes'
  )
end
