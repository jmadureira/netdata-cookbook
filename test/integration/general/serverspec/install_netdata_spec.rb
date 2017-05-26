require 'spec_helper'

describe 'Netdata installation' do
  describe port(19_999) do
    it { should be_listening }
  end

  describe process('netdata') do
    it { should be_running }
  end
end
