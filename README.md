# Juso

<div align="center">
  <img width="300" src="misc/juso.png" alt="juso"/>
</div>

Juso is simple, fast and explicit JSON Serializer.  
Juso means 13 (thirteen) in Japanese.

## Motivation

#### Japanese

Juso は juso というメソッドを定義することで JSON 化が可能になります。Ruby の Hash や Array を用いて定義すれば良いので、覚えることが非常に少ないことが特徴です。また、暗黙的な挙動で非公開にすべき属性が公開されることを防ぎます。

Ruby on Rails においては Model のクラスにそのまま定義することができるため、初期の導入としてはシンプルでわかりやすいです。[^1]

[^1]: as_json メソッドで頑張ることもできますが、より宣言的で分かりやすいはずです

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'juso'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install juso

## Usage

1. Include `Juso::Serializable` to your class.
2. Define juso(context) method.
3. Use Juso.generate(object) method to generate json.

```ruby
class User < ApplicationRecord
  include Juso::Serializable

  # ...

  def juso(context)
    {
      id: id,
      nickname: nickname,
    }
  end
end

class Team < ApplicationRecord
  include Juso::Serializable

  has_many :users

  # ...

  def juso(context)
    {
      id: id,
      name: name,
      users: users
    }
  end
end
```

```ruby
team = Team.first!
Juso.generate(team)
=> {"id":1, name: "team name", users: [{id:1,nickname:"hoge"},{id:2,nickname:"piyo"}]}
```

### Rule of juso

#### Japanese

juso メソッドは以下のクラスのインスタンスしか返してはいけません

- Numeric
- String
- NilClass
- TrueClass
- FalseClass
- Hash
- Array
  - - ActiveRecord::Relation
- Juso::Serializable を include したクラス
- Date / DateTime
  - - ActiveSupport::TimeWithZone

再帰的に juso の処理が適用されるため、Array の要素や Hash の value も同様のルールが適用されます

### Juso::Context

#### Japanese

juso メソッドには Context オブジェクトが渡されます。これによって、Juso.generate から各 juso メソッドにシリアライズのオプションを伝播させることができます

### Juso.wrap

```ruby
class UserSerializer
  include Juso::Serializable

  # ...

  def juso(context)
    {
      id: @user.id,

      # use PostSerializer#juso method. Each post passes into PostSerializer object.
      posts: Juso.wrap(@user.posts, PostSerializer),

      # use Team#juso method
      team: @user.team,
    }
  end
end

class PostSerializer
  include Juso::Serializable

  def initialize(post)
    @post = post
  end

  def juso(context)
    # do something with @post...
  end
end
```

#### Japanese

Juso.wrap(object, serializable_class) ユーティリティを使うことで、特定のクラスに処理を委譲できます。
コード例だと、 @user.posts は Post の ActiveRecord::Relation を返しますが、通常であれば Post インスタンスの juso メソッドが使われるのに対して、各 Post インスタンスを PostSerializer でラップします。PostSerializer#juso メソッドが呼ばれることになります。

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/juso. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/juso/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Juso project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/juso/blob/main/CODE_OF_CONDUCT.md).
