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
