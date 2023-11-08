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

netdata_stream 'stream' do
  configurations(
    'enabled' => 'yes',
    'destination' => 'netdata_master:19999',
    'api key' => '11111111-2222-3333-4444-555555555555'
  )
end

netdata_stream '11111111-2222-3333-4444-555555555555' do
  configurations(
    'enabled' => 'yes'
  )
end

netdata_config 'plugin:proc:/proc/meminfo' do
  configurations(
    'committed memory' => 'yes',
    'writeback memory' => 'yes'
  )
end

netdata_python_plugin 'mysql' do
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

netdata_statsd_plugin 'test_app' do
  app_configuration(
    'metrics' => 'app.*'
  )
  charts(
    'mem' => {
      'name' => 'heap',
      'title' => 'Heap Memory',
      'dimension' => 'app.memory.heap.used used last 1 1000000'
    }
  )
end
