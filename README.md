# Sidekiq-Smart-Killer

[![Gem Version](https://badge.fury.io/rb/sidekiq-smart-killer.svg)](http://badge.fury.io/rb/sidekiq-smart-killer)
[![Build Status](https://github.com/ondrejbartas/sidekiq-smart-killer/workflows/CI/badge.svg?branch=master)](https://github.com/ondrejbartas/sidekiq-smart-killer/actions)
[![Coverage Status](https://coveralls.io/repos/github/ondrejbartas/sidekiq-smart-killer/badge.svg?branch=master)](https://coveralls.io/github/ondrejbartas/sidekiq-smart-killer?branch=master)

## Changelog

Before upgrading to a new version, please read our [Changelog](Changes.md).

## Installation

### Requirements

- Redis 2.8 or greater is required. (Redis 3.0.3 or greater is recommended for large scale use)
- Sidekiq 5, or 4, or 3 and greater is required (for Sidekiq < 4 use version sidekiq-smart-killer 0.3.1)

Install the gem:

```
$ gem install sidekiq-smart-killer
```

Or add to your `Gemfile` and run `bundle install`:

```ruby
gem "sidekiq-smart-killer"
```

**NOTE** If you are not using Rails, you need to add `require 'sidekiq-smart-killer'` somewhere after `require 'sidekiq'`.

## Getting Started

## Contributing

**Thanks to all [contributors](https://github.com/ondrejbartas/sidekiq-smart-killer/graphs/contributors), you’re awesome and this wouldn’t be possible without you!**

* Check out the latest master to make sure the feature hasn't been implemented or the bug hasn't been fixed yet.
* Check out the issue tracker to make sure someone already hasn't requested it and/or contributed it.
* Fork the project.
* Start a feature/bugfix branch.
* Commit and push until you are happy with your contribution.
* Make sure to add tests for it. This is important so we don't break it in a future version unintentionally.

### Testing

You can execute the test suite by running:

```
$ bundle exec rake test
```

## License

Copyright (c) 2013 Ondrej Bartas. See [LICENSE](LICENSE.txt) for further details.
