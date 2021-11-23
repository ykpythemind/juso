# Juso

Juso is JSON Serializer

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

1. include `Juso::Serializable`
2. define juso_json(context) method

```ruby
class User
  include Juso::Serializable

  # ...

  def juso_json(context)
    h = {
      id: id,
      nickname: nickname,
    }

    if context.serializer_type == :admin
      h[:email] = email
    end

    h
  end
end

class Team
  include Juso::Serializable

  # ...

  def juso_json(context)
    {
      id: id,
      name: name,
      users: users
    }
  end
end

team = Team.first!
Juso.generate(team)
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/juso. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/[USERNAME]/juso/blob/main/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Juso project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/juso/blob/main/CODE_OF_CONDUCT.md).
