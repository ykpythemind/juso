# frozen_string_literal: true

require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.libs << "lib"

  list = FileList["test/juso_test.rb"]

  if ENV['RAILS_TEST']
    list << 'test/rails_test.rb'
  end

  t.test_files = list
end

require "rubocop/rake_task"

RuboCop::RakeTask.new

task default: %i[test rubocop]
