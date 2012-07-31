module Scanner
  class Token
    attr_reader :symbol, :content, :line, :column

    def initialize(symbol, content, line, column)
      @symbol = symbol
      @content = content
      @line = line
      @column = column
    end

    def is?(symbol)
      @symbol == symbol
    end

    def is_not?(symbol)
      not is? symbol
    end
  end
end

