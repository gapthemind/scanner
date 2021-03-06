# Scanner
[![Code Climate](https://codeclimate.com/github/gapthemind/scanner.png)](https://codeclimate.com/github/gapthemind/scanner) 

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

For example

    class TestScanner
      include Scanner
      ignore '\s+'
      token :number, '\d+'
      token :id, '[a-z]+'
    end

    @scanner = TestScanner.new
    @scanner.parse("123")
    @scanner.look_ahead.is?(:number) # Should be true

### Token definition
Each token is defined by a symbol, used to identify the token, and a
regular expression that the token should match. An optional third
parameter accepts a hash of options that we will explore later. For
example

    token :number, '\d+'

will match strings containing digits.

Some care is needed when defining tokens that collide with other
tokens. For instance, a languange may define the token '==' and the
token '='. You need to define the double equals before the single
equals, otherwise the string '==' will be identified as two '=' tokens,
instead of a '==' token. 

### Ignoring characters
For many scanning needs, there is a set of characters that is safely
ignored, for instace, in many programming languages, spaces and
newlines. You can define the set of characters to ignore with the
following definition:

    ignore '[\s|\n]+'

### Defining keywords
For many scanning needs, there is a set of tokens that define the
reserved words or keywords of a language. For instance, in Ruby, the
tokens 'def', 'class', 'module', and so on, are language reserved words.
Usually, these tokens are a subset of a larger token group, called
identifiers or ids. You can define a family of reserved words by using
the 'keywords' function. 

    ignore '[\s|\n]+'
    token :id, '[a-z]+'
    keywords %w{def class module}

    @scanner.parse("other def")
    @scanner.lookahead.is?(:id)
    @scanner.lookahead(2).is?(:def)

Note that you will need to have a token definition that matches those
keywords, as the token :id in the previous example.

### Consuming tokens and looking ahead
The Scanner method consume will try to match the first token remaining
in the input string. If successful, it will return the token, and remove
it from the input string.
    
    ignore '[\s|\n]+'
    token :id, '[a-z]+'

    @scanner.parse("one two")
    @scanner.consume.content == "one"
    @scanner.consume.content == "two"

Lookahead performs a similar function, but without removing the token
from the string. It accepts an optional parameter indicating the number
of tokens to look ahead.

    @scanner.parse("one two")
    @scanner.lookahead.content == "one"
    @scanner.lookahead(2).content == "two"

### End of file

    ignore '\s+'
    token :number, '\d+'
    token :id, '[a-z]+'

    @scanner = TestScanner.new
    @scanner.parse("123 abc 456 other")
    begin
      token = @scanner.consume
      puts token.content
    end while token.is_not? :eof

You need you have reached the end of the parse string when you receive
the :eof token. For instance

### Looping through tokens
A scanner instance is a ruby Enumerable, so you can use each, map, and
others.

      @scanner.parse("123 456")
      @scanner.map { |tok| "-#{tok.content}-" }

### Token separation
Sometimes it is necessary to indicate that a given token needs to be
followed by a token separator. For instance, in this example

      token :number, '\d+'
      token :id, '[a-z]+'

The string "abc123" will be parsed as an :id followed by a :number,
which may be undesirable. You may want to indicate that a token
separator (commonly spaces, arithmetic operators, puntuation marks, 
etc) needs to occur after :id or :number.

The following code requires a space after ids and numbers:

      token :number, '\d+', check_for_token_separator: true
      token :id, '[a-z]+', check_for_token_separator: true
      token_separator '\s'

### Looking ahead for token types
When scanning strings, it is often necessary to lookahead to check what
types of tokens are coming. For instance:

    if @scanner.lookahead.is?(:id) && @scanner.lookahead(2).is(:equal)
      # variable assignment

Scanner provides a few utility functions to make this type of check
easier. For instance, the previous code could be refactored to:

    if @scanner.tokens_are?(:id, :equal)

The other two methods available are token_is? and token_is_not?.

### Tokens
The tokens returned by consume and lookahead have a few  methods, which
should be self explanatory: 

* content
* line
* column
* is? => Checks that the token is of a given type
* is_not? => The opposite

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
