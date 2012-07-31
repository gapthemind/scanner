module Scanner

  def token(token_symbol, regular_expression)
    @language_tokens[token_symbol] = regular_expression
  end

  def ignore(regular_expression)
    @ignore = regular_expression
  end

  def parse(program)
    @program = program
    @token_list = []
    @language_tokens = {}
    @ignore = nil
    token :eof, /\A\z/
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

  def consume_next_token
    clear_ignore_text

    @language_tokens.each do |symbol, reg_exp|
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
    consume_regular_expression(@ignore) if @ignore
  end


end
