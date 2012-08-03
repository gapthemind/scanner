require "spec_helper"

describe Scanner do
  before(:each) do
    class TestScanner
      include Scanner
      ignore '[\s|\n]+'
      token :number, '\d+', check_for_token_separator: true
      token :id, '[a-z]+', check_for_token_separator: true
      keywords %w{if}
      token_separator '\s'
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
      @scanner.parse("  \n 123")
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

  describe "line number" do
    it "starts with one" do
      @scanner.parse("123")
      @scanner.consume.line.should eq 1
    end

    it "increases after newlines" do
      @scanner.parse("\n\n123")
      @scanner.consume.line.should eq 3
    end
  end

  describe "column number" do
    it "starts with one" do
      @scanner.parse("123")
      @scanner.consume.column.should eq 1
    end

    it "increases after tokens are consumed" do
      @scanner.parse("123 abc")
      @scanner.consume # 123
      @scanner.consume.column.should eq 5
    end

    it "resets after new lines" do
      @scanner.parse("123\n abc")
      @scanner.consume # 123
      @scanner.consume.column.should eq 2
    end
  end

  describe "keywords" do
    it "a keyword is identified as such" do
      @scanner.parse("if")
      @scanner.consume.is?(:if).should be true
    end
  end

  describe "token is?" do
    it "correctly identifies token to come" do
      @scanner.parse("if")
      @scanner.token_is?(:if).should be true
    end
  end

  describe "token is not?" do
    it "correctly identifies tokens that aren't" do
      @scanner.parse("if")
      @scanner.token_is_not?(:id).should be true
    end

    it "return false if the token is the one in the parameter" do
      @scanner.parse("if")
      @scanner.token_is_not?(:if).should be false
    end
  end

  describe "tokens are?" do
    it "correctly identifies valid sequences" do
      @scanner.parse("if other 123")
      @scanner.tokens_are?(:if, :id, :number).should be true
    end

    it "correctly identifies invalid sequences" do
      @scanner.parse("if other 123")
      @scanner.tokens_are?(:if, :id, :id).should be false
    end
  end

  describe "token separator" do
    it "fails to recognise token without separator" do
      @scanner.parse("other123")
      lambda { @scanner.consume }.should raise_error
    end

    it "works if token after is eof" do
      @scanner.parse("123")
      @scanner.consume.is?(:number).should be true
    end
  end

end
