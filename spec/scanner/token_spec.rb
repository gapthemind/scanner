require 'spec_helper'

describe Scanner::Token do

  it "is the right type of token" do
    @token = Scanner::Token.new(:token_symbol, "content", 0, 0)
    @token.is?(:token_symbol).should be true
  end

  it "is not the wrong type of token" do
    @token = Scanner::Token.new(:token_symbol, "content", 0, 0)
    @token.is_not?(:other_token_symbol).should be true
  end

end

