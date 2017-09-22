require 'foodcritic'
require 'kitchen'
require 'rspec/core/rake_task'
require 'cookstyle'
require 'rubocop/rake_task'

namespace :style do
  desc 'Check Ruby style'
  RuboCop::RakeTask.new :ruby

  desc 'Check Chef style'
  FoodCritic::Rake::LintTask.new :chef do |task|
    task.options = { fail_tags: %w(any) }
  end
end

desc 'Check all styling'
task style: %w(style:ruby style:chef)

namespace :test do
  desc 'Run unit tests'
  RSpec::Core::RakeTask.new :unit

  desc 'Run integration tests'
  task :integration do
    Kitchen.logger = Kitchen.default_file_logger
    Kitchen::Config.new.instances.each { |instance| instance.test :always }
  end
end

desc 'Run tests'
task test: %w(test:unit test:integration)

task default: %w(style test:unit)
