require "spec_helper"

describe Scanner do
  before(:each) do
    @scanner = Object.new
    @scanner.extend(Scanner)
  end

  it "should be able to detect end of line" do
    @scanner.parse("")
    @scanner.consume.is?(:eof).should be true
  end

end
