# frozen_string_literal: true

require "test_helper"

class JusoTest < Minitest::Test
  class User
    include Juso::Serializable

    def initialize(id:, nickname:)
      @id = id
      @nickname = nickname
    end

    def juso_json(*)
      {
        id: @id,
        nickname: @nickname,
      }
    end
  end

  class Team
    include Juso::Serializable

    def initialize(id:, name:, users:)
      @id = id
      @name = name
      @users = users
    end

    def juso_json(*)
      {
        id: @id,
        name: @name,
        users: @users
      }
    end
  end

  def setup
    @users = [User.new(id: 1, nickname: 'ykpythemind'), User.new(id: 2, nickname: 'hogefuga')]

    @team = Team.new(id: 1, name: 'strong team', users: @users)
  end

  def test_that_it_has_a_version_number
    refute_nil ::Juso::VERSION
  end

  def test_serialize_json
    expected = <<-JSON
{"id":1,"name":"strong team","users":[{"id":1,"nickname":"ykpythemind"},{"id":2,"nickname":"hogefuga"}]}
    JSON

    assert_equal expected.strip, Juso.generate(@team)
  end
end
