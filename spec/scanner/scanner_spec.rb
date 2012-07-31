require "spec_helper"

describe Scanner do
  before(:each) do
    class TestScanner
      include Scanner
      ignore /\s+/
      token :number, /\d+/
      token :id, /\w+/
    end

    @scanner = TestScanner.new
  end

  it "detects the end of line" do
    @scanner.parse("")
    @scanner.consume.is?(:eof).should be true
  end

  describe "consume" do

    it "consume returns the next token" do
      @scanner.parse("123")
      token = @scanner.consume
      token.is?(:number).should be true
      token.content.should eq("123")
    end

    it "consume clears ignore tokens before token" do
      @scanner.parse("   123")
      token = @scanner.consume
      token.is?(:number).should be true
    end
  end

  describe "lookahead" do
    it "returns the next token without arguments" do
      @scanner.parse("123")
      @scanner.look_ahead.is?(:number).should be true
    end

    it "does not consume the token" do
      @scanner.parse("123")
      @scanner.look_ahead
      @scanner.consume.is?(:number).should be true
    end

    it "returns look ahead of n elements" do
      @scanner.parse("123 abc")
      @scanner.look_ahead(2).is?(:id).should be true
    end
  end


end
