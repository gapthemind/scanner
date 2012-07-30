# Scanner

Scanner is a gem to scan strings for regular expressions, and return
them as tokes, Each token will be identified by a symbol, and contain
some extra information, like the line and column number.

## Installation

Add this line to your application's Gemfile:

    gem 'scanner'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install scanner

## Usage

Scanner is a module that you can include in your classes. It defines a
token function that accepts the regular expression that the token
matches.

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
