class ResourceQueryService
  attr_reader :payload, :inner_scope, :calculator

  def initialize(payload, inner_scope: nil)
    @payload = payload.deep_dup
    # A counter that is used to give each lookup table alias a unique number
    # to prevent alias conflicts when chaining lookups that return values at
    # the same path, e.g. lookup_s(lookup_s("a", "b"), "b")
    # In this example, both lookups will end up with the same assigned table
    # alias.
    @lookup_id = 0
    @inner_scope = inner_scope
    @calculator = Keisan::Calculator.new(allow_blocks: false, allow_multiline: false)
  end

  def apply(scope)
    if inner_scope.nil?
      @inner_scope = scope
    end

    scope = apply_generators(scope)
    scope = apply_filters(scope)
    scope = apply_sorts(scope)
    scope
  end

  private

  def boolean_function?(ast)
    if ast.is_a?(Keisan::AST::Function)
      %w(
        and
        or
        st_within
        st_intersects
        is_even
        is_odd
        like
        unlike
      ).include?(ast.name)
    else
      return false
    end
  end

  protected

  def next_lookup_id
    @lookup_id += 1
  end

  # Generate an expression that returns a column (or JSON attribute property)
  # identifier given the provided table alias.
  def column_name(scope, table_alias, identifier)
    if scope.column_names.include?(identifier)
      "(#{table_alias}.#{identifier})"
    else
      raise Kaprella::Errors::UnknownPropertyIdentifier.new(identifier)
    end
  end

  # Apply an expression to the given scope
  def apply_expression(scope, expression)
    ast = calculator.ast(expression)
    apply_ast(scope, ast)
  end

  def apply_sort_expression(scope, expression)
    ast = calculator.ast(expression)
    if !ast.is_a?(Keisan::AST::Function) || !%w(asc desc).include?(ast.name)
      raise Kaprella::Errors::InvalidSortExpression.new
    end
    scope, sql = apply_ast(scope, ast.children.first)
    return scope, "#{sql} #{ast.name}"
  end

  # Apply a filter expresison to the given scope
  def apply_filter_expression(scope, expression)
    ast = calculator.ast(expression)
    if ast.is_a?(Keisan::AST::LogicalOperator) || boolean_function?(ast)
      apply_ast(scope, ast)
    else
      raise Kaprella::Errors::InvalidFilterExpression.new
    end
  end

  # Query expression function: concat
  # Concatenates arguments and returns a string
  # concat(arg1, arg2, ...)
  def apply_function_concat(scope, ast)
    args = ast.children.map { |arg|
      scope, sql = apply_ast(scope, arg)
      "(#{sql}::text)"
    }

    return scope, "(concat(#{args.join(',')}))"
  end

  # Query expression function: coalesce
  # Return secondary value if the primary value evaluates to NULL
  # coalesce(primary_value, secondary_value)
  def apply_function_coalesce(scope, ast)
    primary, fallback = ast.children
    scope, primary_sql = apply_ast(scope, primary)
    scope, fallback_sql = apply_ast(scope, fallback)
    return scope, "coalesce(#{primary_sql}, #{fallback_sql})"
  end

  # Query expression function: lower
  # Convert a string to lowercase
  # lower(a_string)
  def apply_function_lower(scope, ast)
    scope, str = apply_ast(scope, ast.children.first)
    return scope, "lower(#{str})"
  end

  # Query expression function: upper
  # Convert a string to uppercase
  # upper(a_string)
  def apply_function_upper(scope, ast)
    scope, str = apply_ast(scope, ast.children.first)
    return scope, "upper(#{str})"
  end

  # Query expression function: like
  # Substring comparison
  # like(string1, 'my string%')
  def apply_function_like(scope, ast)
    scope, lval = apply_ast(scope, ast.children.first)
    scope, rval = apply_ast(scope, ast.children.second)
    return scope, "#{lval} like #{rval}"
  end

  # Query expression function: like
  # Substring comparison
  # unlike(string1, 'my string%')
  def apply_function_unlike(scope, ast)
    scope, lval = apply_ast(scope, ast.children.first)
    scope, rval = apply_ast(scope, ast.children.second)
    return scope, "#{lval} not like #{rval}"
  end

  # Query expression function: prop
  # Get the value of a column or JSON attribute property
  # prop(name)
  def apply_function_prop(scope, ast)
    arg = ast.children.first
    if arg.is_a?(Keisan::AST::String)
      col = column_name(scope, scope.table_name, arg.value)
    else # TODO: Fix - this ignores outer prop and simply evals inner arg
      scope, col = apply_ast(scope, arg)
    end
    return scope, col
  end

  def apply_function_to_i(scope, ast)
    scope, sql = apply_ast(scope, ast.children.first)
    return scope, "(#{sql}::integer)"
  end

  def apply_function_to_f(scope, ast)
    scope, sql = apply_ast(scope, ast.children.first)
    return scope, "(#{sql}::float)"
  end

  # Query expression function: sqrt
  # Return the square-root of a number
  # sqrt(5)
  def apply_function_sqrt(scope, ast)
    arg = ast.children.first
    if arg.is_a?(Keisan::AST::Number)
      sql = "#{arg.value}"
    else
      scope, sql = apply_ast(scope, arg)
    end
    return scope, "sqrt(#{sql}::numeric)"
  end

  # Query expression function: pow
  # Raise a number to a given exponent
  # pow(base, exponent)
  def apply_function_pow(scope, ast)
    base, exponent = ast.children
    scope, base = apply_ast(scope, base)
    scope, exponent = apply_ast(scope, exponent)
    return scope, "power(#{base}::numeric, #{exponent}::numeric)"
  end

  # Query expression function: log
  # Return the log of a number, optionally for a given base (default: 10)
  # log(100)
  # log(64, 2)
  def apply_function_log(scope, ast)
    num, base = ast.children
    scope, num = apply_ast(scope, num)
    if base.nil?
      return scope, "log(#{num}::numeric)"
    else
      scope, base = apply_ast(scope, base)
      return scope, "log(#{base}::numeric, #{num}::numeric)"
    end
  end

  # Query expression function: ln
  # Return the natural log of a number
  # ln(a_number)
  def apply_function_ln(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "ln(#{num}::numeric)"
  end

  # Query expression function: exp
  # Raise Euler's number to a given power
  # exp(a_number)
  def apply_function_exp(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "exp(#{num}::numeric)"
  end

  # Query expression function: abs
  # Return the absolute value of a given number
  # abs(a_number)
  def apply_function_abs(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "abs(#{num}::numeric)"
  end

  # Query expression function: floor
  # Return the greatest integer less than the given number
  # floor(a_number)
  def apply_function_floor(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "floor(#{num}::numeric)"
  end

  # Query expression function: ceil
  # Return the smallest integer greater than the given number
  # ceil(a_number)
  def apply_function_ceil(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "ceil(#{num}::numeric)"
  end

  def apply_function_is_even(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "((#{num}::integer) % 2) = 0"
  end

  def apply_function_is_odd(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "((#{num}::integer) % 2) = 1"
  end

  # Query expression function: ceil
  # Return the nearest integer. If the decimal part is greater than or equal
  # to 0.5, the number is rounded up, otherwise it is rounded down.
  # round(1.6)
  def apply_function_round(scope, ast)
    num = ast.children.first
    scope, num = apply_ast(scope, num)
    return scope, "round(#{num}::numeric)"
  end

  # Query expression function: current_date
  # Retrieve the current date, optionally in a given time zone (default: UTC)
  # current_date()
  # current_date('PST')
  def apply_function_current_date(scope, ast)
    if ast.children.empty?
      return scope, "date(current_date at time zone 'UTC')"
    else
      scope, tz = apply_ast(scope, ast.children.first)
      return scope, "date(current_date at time zone #{tz})"
    end
  end

  # Query expression function: current_timestamp
  # Retrieve the current timestamp
  # current_timestamp()
  def apply_function_current_timestamp(scope, ast)
    return scope, "(current_timestamp at time zone 'UTC')"
  end

  # Query expression function: interval
  # Return an interval of time consisting of a given length and unit. The
  # unit can be singular or plural.
  # interval(1, 'day')
  # interval(5, 'years')
  def apply_function_interval(scope, ast)
    scope, amount = apply_ast(scope, ast.children.first)
    scope, unit = apply_ast(scope, ast.children.second)
    return scope, "(concat(#{amount}, ' ', #{unit})::interval)"
  end

  # Query expression function: second
  # Retrieve the second (0-59) of a timestamp
  # second(current_timestamp())
  def apply_function_second(scope, ast)
    scope, timestamp = apply_ast(scope, ast.children.first)
    return scope, "(date_part('second', #{timestamp})::integer)"
  end

  # Query expression function: minute
  # Retrieve the minute (0-59) of a timestamp
  # minute(current_timestamp())
  def apply_function_minute(scope, ast)
    scope, timestamp = apply_ast(scope, ast.children.first)
    return scope, "(date_part('minute', #{timestamp})::integer)"
  end

  # Query expression function: hour
  # Retrieve the hour (0-23) of a timestamp
  # hour(current_timestamp())
  def apply_function_hour(scope, ast)
    scope, timestamp = apply_ast(scope, ast.children.first)
    return scope, "(date_part('hour', #{timestamp})::integer)"
  end

  # Query expression function: day
  # Retrieve the day of the month (1-31)
  # day(current_date())
  def apply_function_day(scope, ast)
    scope, date = apply_ast(scope, ast.children.first)
    return scope, "(date_part('day', #{date})::integer)"
  end

  # Query expression function: day_of_week
  # Retrieve the day of the week (0 - Sunday, 6 - Saturday)
  # day_of_week(current_date())
  def apply_function_day_of_week(scope, ast)
    scope, date = apply_ast(scope, ast.children.first)
    return scope, "(date_part('dow', #{date})::integer)"
  end

  # Query expression function: day_of_year
  # Retrieve the day of year (1-366)
  # day_of_year(current_date())
  def apply_function_day_of_year(scope, ast)
    scope, date = apply_ast(scope, ast.children.first)
    return scope, "(date_part('doy', #{date})::integer)"
  end

  # Query expression function: week_of_year
  # Retrieve the ISO 8601 week of the current year (1-53). The first week of
  # the year contains the first Thursday of the year, even if that puts the
  # week start date (Monday) in the previous calendar year.
  # week_of_year(current_date())
  def apply_function_week_of_year(scope, ast)
    scope, date = apply_ast(scope, ast.children.first)
    return scope, "(date_part('week', #{date})::integer)"
  end

  # Query expression function: month
  # Retrieve the month of year (1-12)
  # month(current_date())
  def apply_function_month(scope, ast)
    scope, date = apply_ast(scope, ast.children.first)
    return scope, "(date_part('month', #{date})::integer)"
  end

  # Query expression function: month
  # Retrieve the quarter (1-4)
  # quarter(current_date())
  def apply_function_quarter(scope, ast)
    scope, date = apply_ast(scope, ast.children.first)
    return scope, "(date_part('quarter', #{date})::integer)"
  end

  # Query expression function: year
  # Retrieve the calendary year
  # year(current_date())
  def apply_function_year(scope, ast)
    scope, date = apply_ast(scope, ast.children.first)
    return scope, "(date_part('year', #{date})::integer)"
  end

  # Generate a SQL expression for the function specified in the given AST.
  # If applicable, updates and returns the given scope.
  def apply_function(scope, ast)
    case ast.name
    when 'concat'
      apply_function_concat(scope, ast)
    when 'lower'
      apply_function_lower(scope, ast)
    when 'upper'
      apply_function_upper(scope, ast)
    when 'like'
      apply_function_like(scope, ast)
    when 'unlike'
      apply_function_unlike(scope, ast)
    when 'prop'
      apply_function_prop(scope, ast)
    when 'to_i'
      apply_function_to_i(scope, ast)
    when 'to_f'
      apply_function_to_f(scope, ast)
    when 'coalesce'
      apply_function_coalesce(scope, ast)
    when 'sqrt'
      apply_function_sqrt(scope, ast)
    when 'pow'
      apply_function_pow(scope, ast)
    when 'log'
      apply_function_log(scope, ast)
    when 'ln'
      apply_function_ln(scope, ast)
    when 'exp'
      apply_function_exp(scope, ast)
    when 'abs'
      apply_function_abs(scope, ast)
    when 'round'
      apply_function_round(scope, ast)
    when 'floor'
      apply_function_floor(scope, ast)
    when 'ceil'
      apply_function_ceil(scope, ast)
    when 'is_even'
      apply_function_is_even(scope, ast)
    when 'is_odd'
      apply_function_is_odd(scope, ast)
    when 'current_date'
      apply_function_current_date(scope, ast)
    when 'current_timestamp'
      apply_function_current_timestamp(scope, ast)
    when 'interval'
      apply_function_interval(scope, ast)
    when 'second'
      apply_function_second(scope, ast)
    when 'minute'
      apply_function_minute(scope, ast)
    when 'hour'
      apply_function_hour(scope, ast)
    when 'day'
      apply_function_day(scope, ast)
    when 'day_of_week'
      apply_function_day_of_week(scope, ast)
    when 'day_of_year'
      apply_function_day_of_year(scope, ast)
    when 'week_of_year'
      apply_function_week_of_year(scope, ast)
    when 'month'
      apply_function_month(scope, ast)
    when 'quarter'
      apply_function_quarter(scope, ast)
    when 'year'
      apply_function_year(scope, ast)
    when 'lookup_s'
      apply_function_lookup(scope, 'text', ast)
    when 'lookup_i'
      apply_function_lookup(scope, 'integer', ast)
    when 'lookup_f'
      apply_function_lookup(scope, 'float', ast)
    when 'lookup_b'
      apply_function_lookup(scope, 'boolean', ast)
    when 'st_area'
      apply_function_st_area(scope, ast)
    when 'st_centroid'
      apply_function_st_centroid(scope, ast)
    when 'st_point'
      apply_function_st_point(scope, ast)
    when 'st_distance'
      apply_function_st_distance(scope, ast)
    when 'st_within'
      apply_function_st_within(scope, ast)
    when 'st_intersects'
      apply_function_st_intersects(scope, ast)
    when 'st_box'
      apply_function_st_box(scope, ast)
    else
      raise Kaprella::Errors::UndefinedFunctionError.new(ast.name)
    end
  end

  # Return SQL expressions for pre-defined constant values
  def apply_variable(scope, ast)
    case ast.name
    when 'PI'
      return scope, "pi()"
    when 'E'
      return scope, "exp(1.0)"
    end
  end

  def apply_ast_binary_operator(scope, ast, symbol: ast.class.symbol.to_s)
    sql = ast.children.map { |operand|
      scope, operand_sql = apply_ast(scope, operand)
      operand_sql
    }.join(symbol)
    return scope, "(#{sql})"
  end

  def apply_ast_logical_operator(scope, ast)
    case ast
    when Keisan::AST::LogicalEqual
      operator = '='
    when Keisan::AST::LogicalNotEqual
      operator = '!='
    when Keisan::AST::LogicalGreaterThan
      operator = '>'
    when Keisan::AST::LogicalLessThan
      operator = '<'
    when Keisan::AST::LogicalGreaterThanOrEqualTo
      operator = '>='
    when Keisan::AST::LogicalLessThanOrEqualTo
      operator = '<='
    when Keisan::AST::LogicalOr
      operator = 'OR'
    when Keisan::AST::LogicalAnd
      operator = 'AND'
    else
      raise "unknown operator #{ast.class}"
    end
    args = ast.children.map { |arg|
      scope, sql = apply_ast(scope, arg)
      "(#{sql})"
    }
    return scope, "(#{args.join(" #{operator} ")})"
  end

  # Apply a lookup join to the given scope
  #   - scope: The scope to apply the join to
  #   - cast: What type to cast the result as (unused)
  #   - relationship: The relationship to retrieve the property from
  #   - property: Data to be returned from the lookup.
  #
  # Returns the modified scope and generated SQL
  def apply_lookup(scope, cast, relationship, property)
    remote_table_alias = "lookup#{next_lookup_id}___#{relationship.foreign_key}"
    remote_id = "#{remote_table_alias}.id"
    scope = scope.joins(
      <<-SQL
        left join #{relationship.klass.table_name} as #{remote_table_alias}
        on (#{scope.table_name}.#{relationship.foreign_key}::text) = (#{remote_id}::text)
      SQL
    )
    return scope, "(#{column_name(scope, remote_table_alias, property)}::#{cast})"
  end

  # Applies a lookup join to the given scope, returning the result converted
  # to the type provided by the cast argument.
  def apply_function_lookup(scope, cast, ast)
    relationship_arg, property_arg = ast.children

    if !relationship_arg.is_a?(Keisan::AST::Literal)
      raise Kaprella::Errors::GeneratorFunctionArgumentError.new("Argument at index 0 for #{ast.name}() must be a string literal")
    else
      if !scope.model.reflections.include?(relationship_arg.value)
        raise Kaprella::Errors::GeneratorFunctionArgumentError.new("#{scope.model.to_s} has no '#{relationship_arg.value}' relationship")
      end

      relationship = scope.model.reflections[relationship_arg.value]
    end

    if !property_arg.is_a?(Keisan::AST::Literal)
      scope, property = apply_ast(scope, property_arg)
    else
      if !property_arg.value.match(/^[a-zA-Z0-9]+$/)
        raise Kaprella::Errors::GeneratorFunctionArgumentError.new("Argument at index 1 for #{ast.name}() is a literal with disallowed characters")
      end
      property = property_arg.value
      if !property.is_a?(String)
        raise Kaprella::Errors::GeneratorFunctionArgumentError.new("Argument at index 1 for #{ast.name}() must be a string")
      end
    end

    apply_lookup(scope, cast, relationship, property)
  end

  def apply_function_st_point(scope, ast)
    scope, lng = apply_ast(scope, ast.children.first)
    scope, lat = apply_ast(scope, ast.children.second)
    return scope, "st_point(#{lng}, #{lat})"
  end

  def apply_function_st_distance(scope, ast)
    scope, from = apply_ast(scope, ast.children.first)
    scope, to = apply_ast(scope, ast.children.second)
    return scope, "st_distance(#{from}, #{to})"
  end

  def apply_function_st_area(scope, ast)
    scope, sql = apply_ast(scope, ast.children.first)
    return scope, "st_area(#{sql})"
  end

  def apply_function_st_centroid(scope, ast)
    scope, sql = apply_ast(scope, ast.children.first)
    return scope, "st_centroid(#{sql})"
  end

  def apply_function_st_intersects(scope, ast)
    scope, a = apply_ast(scope, ast.children.first)
    scope, b = apply_ast(scope, ast.children.second)
    return scope, "st_intersects(#{a}::geometry, #{b}::geometry)"
  end

  def apply_function_st_within(scope, ast)
    scope, a = apply_ast(scope, ast.children.first)
    scope, b = apply_ast(scope, ast.children.second)
    return scope, "st_within(#{a}::geometry, #{b}::geometry)"
  end

  # Args should be
  # N E S W
  # Y max, X max, Y min, X min
  def apply_function_st_box(scope, ast)
    scope, n = apply_ast(scope, ast.children[0])
    scope, e = apply_ast(scope, ast.children[1])
    scope, s = apply_ast(scope, ast.children[2])
    scope, w = apply_ast(scope, ast.children[3])
    return scope, "st_makeenvelope(#{w}, #{s}, #{e}, #{n}, 4326)"
  end

  def apply_ast(scope, ast)
    case ast
    when Keisan::AST::LogicalOperator
      scope, sql = apply_ast_logical_operator(scope, ast)
    when Keisan::AST::ArithmeticOperator
      scope, sql = apply_ast_binary_operator(scope, ast)
    when Keisan::AST::BitwiseXor
      scope, sql = apply_ast_binary_operator(scope, ast, symbol: '#')
    when Keisan::AST::BitwiseOperator
      scope, sql = apply_ast_binary_operator(scope, ast)
    when Keisan::AST::UnaryInverse
      scope, operand_sql = apply_ast(scope, ast.children.first)
      sql = "(1.0 / (#{operand_sql}))"
    when Keisan::AST::UnaryOperator
      scope, operand_sql = apply_ast(scope, ast.children.first)
      sql = "#{ast.class.symbol.to_s}(#{operand_sql})"
    when Keisan::AST::Variable
      scope, sql = apply_variable(scope, ast)
    when Keisan::AST::Function
      scope, sql = apply_function(scope, ast)
    when Keisan::AST::String
      sql = "#{ActiveRecord::Base.connection.quote(ast.value)}"
    when Keisan::AST::Number
      sql = "#{ast.value}"
    when Keisan::AST::Boolean
      sql = "#{ast.value}"
    else
      sql = 'null'
    end
    return scope, sql
  end

  def apply_sorts(scope)
    sorts = payload.fetch('sort', [])

    if sorts.is_a?(String)
      sorts = [sorts]
    end

    sorts.each { |sort|
      scope, sql = apply_sort_expression(scope, sort)
      scope = scope.order(Arel.sql("#{sql}"))
    }

    return scope
  end

  def apply_filters(scope)
    filters = payload.fetch('filter', [])

    if filters.is_a?(String)
      filters = [filters]
    end

    filters.each { |filter|
      scope, sql = apply_filter_expression(scope, filter)
      scope = scope.where("(#{sql})")
    }

    scope
  end

  def apply_generators(scope)
    generate = payload.fetch('generate', {})

    reserved_identifiers = scope.column_names
    generate.keys.each { |key|
      # Verify that no identifiers exactly match existing attributes.
      # Re-used identifiers will simply be overwritten, but we need to make
      # sure that attributes like namespace can't be replaced.
      if reserved_identifiers.include?(key) || scope.respond_to?(key.to_sym, true)
        raise Kaprella::Errors::RestrictedGeneratedColumnIdentifier.new(key)
      end

      # Check that identifiers are using only alphanumerics and _, and
      # don't start with a number.
      if !key.match(/^[a-zA-Z_]+[a-zA-Z0-9_]*$/)
        raise Kaprella::Errors::InvalidGeneratedColumnIdentifier.new(key)
      end
    }

    generate.each { |identifier, generator|
      generator = URI.decode(generator)
      scope, sql = apply_expression(scope, generator)
      scope = scope.select_append("(#{sql}) as \"#{identifier}\"")
    }

    scope
  end
end
