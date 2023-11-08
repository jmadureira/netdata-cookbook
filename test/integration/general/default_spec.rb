# https://www.inspec.io/docs/reference/resources/

describe port(19999) do
  it { should be_listening }
  its('processes') { should include 'netdata' }
  its('addresses') { should include '127.0.0.1' }
  its('protocols') { should include 'tcp' }
end

describe service('netdata') do
  it { should be_installed }
  it { should be_enabled }
  it { should be_running }
end

describe command("sleep 5; curl -s 'http://localhost:19999/api/v1/allmetrics'") do
  its('stdout') { should match(/NETDATA_SYSTEM_CPU_SYSTEM=.*/) }
end

describe file('/etc/netdata/netdata.conf') do
  its('content') do
    should match(
      %r{[global].*log\sdirectory\s=\s/var/log/netdata}m
    )
  end
  its('content') { should match(/[web].*bind\sto\s=\slocalhost/m) }
  its('content') do
    should match(
      %r{[plugin:proc:/proc/meminfo].*committed\smemory\s=\syes}m
    )
  end
end

describe file('/etc/netdata/python.d/mysql.conf') do
  its('content') { should match(/retries:\s5/) }
  its('content') do
    should match(
      /tcp:.*name:\slocal.*host:\slocalhost.*port:\s3306/m
    )
  end
end

describe file('/etc/netdata/python.d/bind_rndc.conf') do
  its('content') do
    should match(
      %r{local:.*named_stats_path:\s"/custom/path"}m
    )
  end
end

describe file('/etc/netdata/python.d/nginx.conf') do
  its('content') do
    should match(
      %r{localhost:.*name:\slocal.*url:\shttp://localhost/stub_status}m
    )
  end
end
