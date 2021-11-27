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
require 'json_expressions/minitest'

class RailsTest < Minitest::Test
  include Rack::Test::Methods

  def setup
    time = DateTime.new(2021, 5, 20, 10).utc # fixed time for test

    @user1 = User.create!(name: 'ykpythemind', email: 'ykpythemind@example.com')
    @user2 = User.create!(name: 'juso', email: 'juso@example.com')

    post1 = Post.create!(user: @user1, title: 'title1', created_at: time, updated_at: time)
    post2 = Post.create!(user: @user2, title: 'title2', created_at: time, updated_at: time)

    post1.comments.create!(body: 'hey, ykpythemind', user: @user2, anonymous: false)
    post1.comments.create!(body: 'hello, juso', anonymous: true)
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

    pattern = [
      {
        id: 1,
        title: 'title1',
        user: {
          id: Integer, name: 'ykpythemind'
        },
        comment_count: 2,
      },
      {
        id: 2,
        title: 'title2',
        user: {
          id: Integer, name: 'juso'
        },
        comment_count: 0,
      },
    ]

    assert_json_match pattern, last_response.body
  end

  def test_post_show
    get "/posts/#{Post.first!.id}"
    assert last_response.ok?

    puts last_response.body

    pattern = {
      id: Integer,
      comments: [
        { id: 1, body: 'hey, ykpythemind', anonymous: false, user: { id: Integer, name: 'juso' }},
        { id: 2, body: 'hello, juso', anonymous: true, user: nil },
      ],
      user: { id: Integer, name: 'ykpythemind' },
      created_at: '2021-05-20T10:00:00Z',
      updated_at: '2021-05-20T10:00:00Z',
    }

    assert_json_match pattern, last_response.body
  end

  private
    def app
      Rails.application
    end
end
