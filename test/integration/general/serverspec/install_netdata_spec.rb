require "#{ENV['BUSSER_ROOT']}/../kitchen/data/serverspec_helper"

describe 'Netdata installation' do
  it 'has Netdata service port listening' do
    expect(port(19_999)).to be_listening
  end

  it 'has Netdata process running' do
    expect(process('netdata')).to be_running
  end
end
