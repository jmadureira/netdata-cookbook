require 'rspec/core/rake_task'
require 'foodcritic'

desc 'Run Chef style checks'
FoodCritic::Rake::LintTask.new(:style) do |t|
  t.options = {
    :fail_tags => ['any']
  }
end

desc 'Run ChefSpec tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--color'
end

desc 'Run Test Kitchen integration tests'
task :kitchen do
  require 'kitchen'
  Kitchen.logger = Kitchen.default_file_logger
  Kitchen::Config.new.instances.each do |instance|
    instance.test(:always)
  end
end

task :default => %w(spec style)
