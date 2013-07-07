# THis is the module to include in your class to inherit the scanner functionality
module Scanner

  def self.append_features(aModule)
    super

    aModule.instance_eval do
      @language_tokens = {}
      @ignore = nil
      @keywords = nil
      @check_for_token_separator = {}
      @separator = nil

      # defines a token of the language
      # Each token is defined by a symbol, used to identify the token, and a
      # regular expression that the token should match. An optional third
      # parameter accepts a hash of options. For example:
      #
      #     token :number, '\d+'
      #
      # will match strings containing digits.
      #
      # Some care is needed when defining tokens that collide with other
      # tokens. For instance, a languange may define the token '==' and the
      # token '='. You need to define the double equals before the single
      # equals, otherwise the string '==' will be identified as two '=' tokens,
      # instead of a '==' token.
      def token(token_symbol, regular_expression, options = {})
        modified_reg_exp = "\\A#{regular_expression}"
        @language_tokens[token_symbol] = /#{modified_reg_exp}/
        @check_for_token_separator[token_symbol] = options[:check_for_token_separator] == true
      end

      def ignore(regular_expression)
        modified_reg_exp = "\\A#{regular_expression}"
        @ignore = /#{modified_reg_exp}/
      end

      def keywords(keywords)
        @keywords = keywords
      end

      def token_separator(regular_expression)
        modified_reg_exp = "\\A#{regular_expression}"
        @separator = /#{modified_reg_exp}/
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

  def check_for_token_separator
    self.class.instance_eval { @check_for_token_separator }
  end

  def separator
    self.class.instance_eval { @separator }
  end

  public

  include Enumerable

  # Sets the string to parse
  def parse(program)
    @program = program
    @token_list = []
    @line_number = 1
    @column_number = 1
    @token_number = 0
  end

  def consume
    if @token_number >= @token_list.size
      consume_next_token
    end
    token = @token_list[@token_number]
    @token_number+=1
    token
  end

  def look_ahead(number_of_tokens = 1)
    while @token_list.size < @token_number + number_of_tokens
      consume_next_token
    end
    @token_list[@token_number + number_of_tokens - 1]
  end

  def token_is?(token_type)
    look_ahead.is? token_type
  end

  def token_is_not?(token_type)
    not (look_ahead.is? token_type)
  end

  def tokens_are?(*tokens)
    look_ahead_index = 1
    tokens.each do |token|
      return false unless look_ahead(look_ahead_index).is? token
      look_ahead_index += 1
    end
    return true
  end

  def each
    local_index = 0
    begin
      if local_index >= @token_list.size
        consume_next_token
      end
      current_token = @token_list[local_index]
      if current_token.is_not? :eof
        yield current_token
      end
      local_index += 1
    end while current_token.is_not? :eof
  end

  private


  def consume_next_token
    clear_ignore_text

    currently_at_column = @column_number
    language_tokens.each do |symbol, reg_exp|
      if @program =~ reg_exp
        content, token_type = get_token_from_reg_exp(reg_exp, symbol)
        if check_for_token_separator[symbol]
          check_for_separator
        end
        @token_list << Token.new(token_type, content, @line_number, currently_at_column)
        return
      end
    end

    throw :scanner_exception
  end

  def check_for_separator
    eof = language_tokens[:eof]
    throw :scanner_exception unless @program =~ separator || @program =~ eof
  end

  def get_token_from_reg_exp(reg_exp, symbol)
    content = consume_regular_expression(reg_exp)
    if keywords && keywords.include?(content)
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
