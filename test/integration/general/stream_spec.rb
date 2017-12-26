# https://www.inspec.io/docs/reference/resources/

describe service('netdata') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/netdata/stream.conf') do
  its('content') { should match(/[stream].*enabled\s=\syes/m) }
end
