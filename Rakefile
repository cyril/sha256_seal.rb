require 'bundler/gem_tasks'
require 'rake/testtask'
require 'rubocop/rake_task'

RuboCop::RakeTask.new

Rake::TestTask.new do |t|
  t.verbose = true
  t.warning = true
  t.pattern = File.join('fix', '**', '*_fix.rb')
end

namespace :test do
  task :coverage do
    ENV['COVERAGE'] = 'true'
    Rake::Task['test'].invoke
  end
end

task default: %i[test]
