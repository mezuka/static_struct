[![Build Status](https://travis-ci.org/mezuka/static_struct.svg?branch=master)](https://travis-ci.org/mezuka/static_struct)

# StaticStruct

Convert Ruby hashes (or hash-like objects) into Ruby objects.

Key features:

* Nesting hashes and respond to objects `to_hash` methods are allowed to do the conversation;
* There are no limitations of the nesting;
* It is not possible to call undefined methods;
* The defined dynamically structure is iterable (responds to `each`);
* The converted structure is *readonly*. It's not possible to rewrite defined values someway.

## Installation

Add this line to your application's `Gemfile`:

```ruby
gem 'static-struct', require 'static_struct'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install static_struct

## Motivation

What the problem solves the gem? Well, it's very straightforward to explain. Lately we are facing the issues
that covert Ruby objects into JSON in order to respond it to the client more often. It's rather easy task
and may be solved without any third-party libraries. Commonly the Ruby objects are transformed into
`Hash`'es and then - into JSON. The client side receives the formed JSON and in JavaScript (as usual)
we are free to use the JSON properties via `.` call (`{foo: 'bar'}` can be called as `foo.bar`).

Getting properties via `.` notation is more convenient in JavaScript versus getting them via `[]`.
But in Ruby it's more robust and safe in addition to the convenience. That means, it's not possible
to call undefined methods in Ruby. We just get exceptions with well explained messages in such cases.
And this is cool - having early exceptions in our Ruby code makes application bug free, allows to
reduce debugging time when something goes wrong. As more code with incorrect state we have in Ruby as
more we spend time in debugging. But debugging Ruby code is awful and should be reduced.

Ok, we have peace of code on the server side that generates `Hash` with necessary structure for the client side.
But later we need to send emails based on the same structure as the client renders `HTML`. Commonly
emails are rendered on the server side and that means that we have a dilemma here: from one side we
could use the generated `Hash` there but this is not a convenient and robust solution as we already
figured out; from other side we could transform the `Hash` into a Ruby objects structure, that's
correct solution but the problem is that there is no a good ready library for this. So, here this gem comes
to the help. It allows to create a robust Ruby objects structure given the `Hash`.

Others say that we could use [ostruct](http://ruby-doc.org/stdlib-2.0.0/libdoc/ostruct/rdoc/OpenStruct.html) or [hashie](https://github.com/intridea/hashie) in order to solve the problem. But they don't solve one
important issue - when there is no defined property on the structure there should be an **exception**.
Only this way we make a profit reducing bugs and debugging time.

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
struct.enum_for(:each).map do |key, val|
  [key, val]
end # => [["foo", "bar"], ["foo_foo", #<Enumerator: #<StaticStruct::Structure foo = bar>:each>]]
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/mezuka/static_struct. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

