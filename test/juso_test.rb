# frozen_string_literal: true

require "test_helper"

class JusoTest < Minitest::Test
  class User
    include Juso::Serializable

    def initialize(id:, nickname:, email:)
      @id = id
      @nickname = nickname
      @email = email
    end

    def as_juso_json(context)
      h = {
        id: @id,
        nickname: @nickname,
      }

      if context.serializer_type == :admin
        h[:email] = @email
      end

      h
    end
  end

  class Team
    include Juso::Serializable

    def initialize(id:, name:, users:)
      @id = id
      @name = name
      @users = users
    end

    def as_juso_json(context)
      {
        id: @id,
        name: @name,
        users: @users
      }
    end
  end

  class History
    include Juso::Serializable

    def initialize(time)
      @time = time
    end

    def as_juso_json(context)
      { at: @time }
    end
  end

  class UserWithoutJuso
  end

  def setup
    @users = [
      User.new(id: 1, nickname: 'ykpythemind', email: 'ykpy@example.com'),
      User.new(id: 2, nickname: 'hogefuga', email: 'fuga@example.com'),
    ]

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

  def test_juso_context
    context = Juso::Context.new(serializer_type: :admin)

    expected = '{"id":1,"nickname":"ykpythemind","email":"ykpy@example.com"}'

    assert_equal expected, Juso.generate(@users[0], context: context)

    all = JSON.parse(Juso.generate(@users, context: context))
    assert_equal ['ykpy@example.com', 'fuga@example.com'], all.map { |t| t['email'] }
  end

  def test_serialize_error
    user = UserWithoutJuso.new

    err = assert_raises(Juso::Error) do
      Juso.generate(user)
    end

    assert_match /you must include Juso::Serializable/, err.message
  end

  def test_number
    h = {
      a: 1,
      b: -100,
      c: 10.01
    }

    json = Juso.generate(h)
    puts json
  end

  def test_datetime
    day = DateTime.parse('2001-02-03T04:05:06.123456789+09:00')

    assert_equal '{"at":"2001-02-03T04:05:06+09:00"}', Juso.generate(History.new(day))
  end
end
