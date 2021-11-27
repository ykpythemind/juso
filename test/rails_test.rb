# frozen_string_literal: true

require "test_helper"

# Configure Rails Environment
ENV["RAILS_ENV"] = "test"

require_relative "../test/dummy/config/environment"
ActiveRecord::Migrator.migrations_paths = [File.expand_path("../test/dummy/db/migrate", __dir__)]
require "rails/test_help"

require "rails/test_unit/reporter"
Rails::TestUnitReporter.executable = 'bin/test'

# Load fixtures from the engine
if ActiveSupport::TestCase.respond_to?(:fixture_path=)
  ActiveSupport::TestCase.fixture_path = File.expand_path("fixtures", __dir__)
  ActionDispatch::IntegrationTest.fixture_path = ActiveSupport::TestCase.fixture_path
  ActiveSupport::TestCase.file_fixture_path = ActiveSupport::TestCase.fixture_path + "/files"
  ActiveSupport::TestCase.fixtures :all
end

require "rack/test"

class RailsTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    @user1 = User.create!(name: 'ykpythemind', email: 'ykpythemind@example.com')
    @user2 = User.create!(name: 'juso', email: 'juso@example.com')

    post1 = Post.create!(user: @user1, title: 'title1')
    post2 = Post.create!(user: @user2, title: 'title2'),

    post1.comments.create!(body: 'hey, ykpythemind', user: @user2)
    post1.comments.create!(body: 'hello, juso', user: @user1)
  end

  def teardown
    Comment.delete_all
    Post.delete_all
    User.delete_all
  end

  def test_posts
    get "/posts"
    assert last_response.ok?
    puts last_response.body
  end

  # def test_posts
  # end

  private
    def app
      Rails.application
    end
end
