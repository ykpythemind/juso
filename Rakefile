# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"

  files = FileList["test/juso_test.rb"]

  if ENV['RAILS_TEST']
    files << 'test/rails_test.rb'
  end

  t.test_files = files
end

# require "rubocop/rake_task"
# RuboCop::RakeTask.new

task default: %i[test]
