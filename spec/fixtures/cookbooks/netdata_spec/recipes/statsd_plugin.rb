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
