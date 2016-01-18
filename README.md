[![Build Status](https://travis-ci.org/mezuka/static_struct.svg?branch=master)](https://travis-ci.org/mezuka/static_struct)

# StaticStruct

Convert Ruby hashes (or hash-like objects) into Ruby objects.

Key features:

* Nesting hashes and respond to objects `to_hash` methods are allowed to do the convertation;
* There are no limitations of the nesting;
* It is not possible to call undefined methods;
* The converted structure is *readonly*. It's not possible to rewrite defined values someway.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'static-struct', require 'static_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install static_struct

## Usage

```ruby
class ImplicitHash
  def to_hash
    {foo: 'bar'}
  end
end

hash = {
  foo: 'bar',
  foo_foo: ImplicitHash.new
}

struct = StaticStruct::Structure.new(hash)
struct.foo # => 'bar'
struct.foo_foo.foo # => 'bar'
struct.foo_fake # => NoMethodError: undefined method `foo_fake'
struct.foo = 'new bar' # => NoMethodError: undefined method `foo='
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mezuka/static_struct. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

