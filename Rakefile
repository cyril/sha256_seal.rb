# frozen_string_literal: true

require "bundler/gem_tasks"

require "rubocop/rake_task"
RuboCop::RakeTask.new

require "yard"
YARD::Rake::YardocTask.new

require "rake/testtask"

Rake::TestTask.new do |t|
  t.verbose = true
  t.warning = true
  t.pattern = File.join("fix", "**", "*_fix.rb")
end

namespace :test do
  desc "Code coverage"
  task :coverage do
    ENV["COVERAGE"] = "true"
    Rake::Task["test"].invoke
  end
end

task default: %i[yard rubocop:auto_correct test]
