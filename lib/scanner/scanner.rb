module Scanner

  def self.append_features(aModule)
    super

    aModule.instance_eval do
      @language_tokens = {}
      @ignore = nil
      @keywords = nil

      def token(token_symbol, regular_expression)
        modified_reg_exp = "\\A#{regular_expression}"
        @language_tokens[token_symbol] = /#{modified_reg_exp}/
      end

      def ignore(regular_expression)
        modified_reg_exp = "\\A#{regular_expression}"
        @ignore = /#{modified_reg_exp}/
      end

      def keywords(keywords)
        @keywords = keywords
      end

      token :eof, '\z'
    end

  end

  private
  def language_tokens
    self.class.instance_eval { @language_tokens }
  end

  def ignore
    self.class.instance_eval { @ignore }
  end

  def keywords
    self.class.instance_eval { @keywords }
  end

  public

  def parse(program)
    @program = program
    @token_list = []
    @line_number = 1
    @column_number = 1
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
      token = consume_next_token
      @token_list << token
      end_of_file_met = token.is? :eof
    end
    @token_list[-1]
  end

  private


  def consume_next_token
    clear_ignore_text

    currently_at_column = @column_number
    language_tokens.each do |symbol, reg_exp|
      if @program =~ reg_exp
        content, token_type = get_token_from_regexp(regexp)
        return Token.new(token_type, content, @line_number, currently_at_column)
      end
    end

    throw :scanner_exception
  end

  def get_token_from_regexp(regexp)
    content = consume_regular_expression(reg_exp)
    if keywords.include? content
      token_type = content.to_sym
    else
      token_type = symbol
    end
    return content, token_type
  end

  def consume_regular_expression(regexp)
    content = @program[regexp]
    @program.gsub!(regexp,"")
    calculate_position_after content
    content
  end

  def clear_ignore_text
    consume_regular_expression(ignore) if ignore
  end

  def calculate_position_after(content)
    if content
      number_of_new_lines = content.scan(/\n/).size
      if number_of_new_lines > 0
        @line_number += number_of_new_lines
        @column_number = content.gsub(/.*\n/,"").length + 1
      else
        @column_number += content.length
      end
    end
  end
end
