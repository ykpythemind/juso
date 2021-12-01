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

    attr_reader :nickname, :id, :email

    def juso(context)
      h = {
        id: @id,
        nickname: @nickname,
      }

      if context.serializer == :admin
        h[:email] = @email
      end

      h
    end
  end

  class Team
    include Juso::Serializable

    attr_reader :id, :name, :users

    def initialize(id:, name:, users:)
      @id = id
      @name = name
      @users = users
    end

    def juso(context)
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

    def juso(context)
      { at: @time }
    end
  end

  class UserWithoutJuso
  end

  class TeamSerializer
    include Juso::Serializable

    def initialize(team)
      @team = team
    end

    def juso(context)
      {
        users: Juso.wrap(@team.users, UserSerializer),
        id: @team.id
      }
    end
  end

  class UserSerializer
    include Juso::Serializable

    def initialize(user)
      @user = user
    end

    def juso(context)
      {
        name: @user.nickname
      }
    end
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
    want = <<-JSON
{"id":1,"name":"strong team","users":[{"id":1,"nickname":"ykpythemind"},{"id":2,"nickname":"hogefuga"}]}
    JSON

    assert_equal want.strip, Juso.generate(@team)
  end

  def test_juso_context
    context = Juso::Context.new(serializer: :admin)

    want = '[{"id":1,"nickname":"ykpythemind","email":"ykpy@example.com"},{"id":2,"nickname":"hogefuga","email":"fuga@example.com"}]'
    got = Juso.generate(@users, context)

    assert_equal want, got
  end

  def test_serialize_error
    user = UserWithoutJuso.new

    err = assert_raises(Juso::Error) do
      Juso.generate(user)
    end

    assert_match(/you must include Juso::Serializable/, err.message)
  end

  def test_number
    h = {
      a: 1,
      b: -100,
      c: 10.01
    }

    assert_equal '{"a":1,"b":-100,"c":10.01}', Juso.generate(h)
  end

  def test_string
    h = {
      a: 'b',
      'c' => nil
    }

    assert_equal '{"a":"b","c":null}', Juso.generate(h)
  end

  def test_datetime
    day = DateTime.parse('2001-02-03T04:05:06.123456789+09:00')

    assert_equal '{"at":"2001-02-03T04:05:06+09:00"}', Juso.generate(History.new(day))

    assert_equal '{"at":"2001-02-03T04:05:06.123+09:00"}', Juso.generate(History.new(day), Juso::Context.new(options: {juso_time_n_digits: 3}))
  end

  def test_wrap
    want = '{"users":[{"name":"ykpythemind"},{"name":"hogefuga"}],"id":1}'
    got = Juso.generate(Juso.wrap(@team, TeamSerializer))

    assert_equal want, got
  end

  def test_array
    user = @users[0]
    want = '[1,"a",{"b":"fuga"},{"name":"ykpythemind"}]'
    got = Juso.generate([1, 'a', {b: 'fuga'}, Juso.wrap(user, UserSerializer)])

    assert_equal want, got
  end
end
