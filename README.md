# Futureshop

[futureshop APIv2](https://www.future-shop.jp/manual/api/api.html) client and tools.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'futureshop'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install futureshop

## Usage

    futureshop orders -fcsv --order-date-start=2016-07-05 --order-date-end=2021-07-20 > orders.2021-07-20.csv
    futureshop inventories --type=regular,preorder

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test-unit` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and merge requests are welcome on GitHub at https://gitlab.com/KitaitiMakoto/futuresohp
