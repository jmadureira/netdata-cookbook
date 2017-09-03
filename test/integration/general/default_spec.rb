# https://www.inspec.io/docs/reference/resources/

describe port(19999) do
  it { should be_listening }
end

describe processes('netdata') do
  it { should exist }
end

describe service('netdata') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe file('/etc/netdata/netdata.conf') do
  its('content') { should match(
    %r{[global].*log\sdirectory\s=\s/var/log/netdata}m
  ) }
  its('content') { should match(%r{[web].*bind\sto\s=\slocalhost}m) }
  its('content') { should match(
    %r{[plugin:proc:/proc/meminfo].*committed\smemory\s=\syes}m
  ) }
end

describe file('/etc/netdata/python.d/mysql.conf') do
  its('content') { should match(%r{retries:\s5}) }
  its('content') { should match(
    %r{tcp:.*name:\slocal.*host:\slocalhost.*port:\s3306}m
  ) }
end

describe file('/etc/netdata/python.d/bind_rndc.conf') do
  its('content') { should match(
    %r{local:.*named_stats_path:\s"/var/log/bind/named.stats"}m
  ) }
end

describe file('/etc/netdata/python.d/nginx.conf') do
  its('content') { should match(
    %r{localhost:.*name:\slocal.*url:\shttp://localhost/stub_status}m
  ) }
end