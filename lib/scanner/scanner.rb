module Scanner

  private
  @language_tokens = {}
  @ignore = nil

  public

  def self.token(token_symbol, regular_expression)
    @language_tokens[token_symbol] = regular_expression
  end

  def self.ignore(regular_expression)
    @ignore = regular_expression
  end

  def parse(program)
    @program = program
    @token_list = []
  end

  def consume
    if @token_list.empty?
      consume_next_token
    else
      @token_list.shift
    end
  end

  def look_ahead(number_of_tokens = 1)
    end_of_file_met = false
    while @token_list.size < number_of_tokens
      throw :scanner_exception if end_of_file_met
      token = consume_token
      @token_list << token
      end_of_file_met = token.is? :eof
    end
    @token_list[-1]
  end

  private

  token :eof, /\A\z/

  def self.language_tokens
    @language_tokens
  end

  def self.ignore
    @ignore
  end

  def consume_next_token
    clear_ignore_text

    self.class.language_tokens.each do |symbol, reg_exp|
      if @program =~ reg_exp
        return Token.new(symbol, consume_regular_expression(reg_exp), 0, 0)
      end
    end

    throw :scanner_exception
  end

  def consume_regular_expression(regexp)
    content = @program[regexp]
    @program.gsub!(regexp,"")
    content
  end

  def clear_ignore_text
    consume_regular_expression(self.class.ignore) if self.class.ignore
  end


end
