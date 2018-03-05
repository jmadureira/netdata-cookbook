netdata_python_plugin 'mysql' do
  global_configuration(
    'retries' => 5
  )
  jobs(
    'tcp' => {
      'name' => 'local',
      'host' => 'localhost',
      'port' => 3306,
    }
  )
end
