class QueryExpressionParser < BabelBridge::Parser
  ignore_whitespace

  binary_operators_rule :binary_expression, :operand, [[:/, :*], [:+, :-], [:<, :<=, :>, :>=, :==, :!=]] do
    def evaluate(scope)
      scope, lval = left.evaluate(scope)
      scope, rval = right.evaluate(scope)
      return scope, "#{lval} #{operator == :== ? '=' : operator} #{rval}"
    end
  end

  rule :expression, any(:related_attribute, :attribute, :string, :number, :boolean, :binary_expression) do
    def evaluate(scope)
      return self.pop_match.evaluate(scope)
    end
  end

  rule :attribute, /[a-zA-Z_]+/ do
    def evaluate(scope)
      if scope.attribute_names.include?(self.text)
        column_name = "#{scope.table_name}.#{self.text}"
        return scope.select_append(column_name), column_name
      else
        return scope, self.text
      end
    end
  end

  rule :related_attribute, :attribute, '.', :attribute do
    def evaluate(scope)
      return scope, self.text
    end
  end

  rule :operand, :expression do
    def evaluate(scope)
      expression.evaluate(scope)
    end
  end

  rule :operand, '(', :expression, ')' do
    def evaluate(scope)
      scope, sql = expression.evaluate(scope)
      return scope, "(#{sql})"
    end
  end

  rule :string, /"(?:[^"\\]|\\(?:["\\\/bfnrt]|u[0-9a-fA-F]{4}))*"/ do
    def evaluate(scope)
      return scope, self.text
    end
  end

  rule :number, /-?(?:0|[1-9]\d*)(?:\.\d+)?(?:[eE][+-]?\d+)?/ do
    def evaluate(scope)
      return scope, self.text
    end
  end

  rule :boolean, /(true|false)/ do
    def evaluate(scope)
      return scope, self.text
    end
  end
end
