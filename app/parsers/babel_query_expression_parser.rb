class BabelQueryExpressionParser < BabelBridge::Parser
  ignore_whitespace

  def parse(expression)
    super("(#{expression})")
  end

  rule :atom, '(', :expression, ')' do
    def evaluate(scope)
      scope, sql = expression.evaluate(scope)
      return scope, "(#{sql})"
    end
  end

  binary_operators_rule(
    :expression,
    :atom,
    [
      [:/, :*],
      [:+, :-],
      [:<, :<=, :>, :>=, :==, :!=]
    ]
  ) do
    def evaluate(scope)
      scope, lval = left.evaluate(scope)
      scope, rval = right.evaluate(scope)
      return scope, "#{lval} #{operator == :== ? '=' : operator} #{rval}"
    end
  end

  rule :atom, any(
    :function,
    :related_count,
    :related_attribute,
    :attribute,
    :string,
    :number,
    :boolean
  )

  rule :function, :attribute, '(', many?(:atom, ','), ')' do
    def evaluate(scope)
      if self.respond_to?(attribute.to_sym)
        self.send(attribute.to_sym, scope, atom)
      else
        raise Kaprella::Errors::InvalidFunctionError.new(attribute)
      end
    end

    def concat(scope, atoms)
      atoms = atoms.map { |atom|
        scope, sql = atom.evaluate(scope)
        sql
      }
      return scope, "concat(#{atoms.join(', ')})"
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
      relationship = attribute[0].text
      column = attribute[1].text
      reflection = scope.model.reflections[relationship]
      if reflection.nil?
        raise Kaprella::Errors::InvalidRelationshipError.new(relationship)
      end
      case reflection
      when ActiveRecord::Reflection::BelongsToReflection,
           ActiveRecord::Reflection::HasOneReflection
        sql = "#{reflection.klass.table_name}.#{column}"
        scope = scope.joins(relationship.to_sym).select_append(sql)
      else
        t = reflection.class.to_s.demodulize.gsub(/Reflection/, '')
        raise Kaprella::Errors::RelationshipTypeError.new(relationship, t)
      end

      return scope, sql
    end
  end

  rule :related_count, :attribute, '.', /count\b/ do
    def evaluate(scope)
      relationship = attribute.text
      reflection = scope.model.reflections[relationship]
      raise Kaprella::Errors::InvalidRelationshipError.new(relationship) if reflection.nil?
      case reflection
      when ActiveRecord::Reflection::HasManyReflection
        column_name = "#{relationship}__count"
        foreign_key = reflection.foreign_key
        primary_key = "#{scope.table_name}.#{scope.primary_key}"
        scope = scope.joins(<<-SQL)
          LEFT JOIN (
            SELECT #{foreign_key}, COUNT(*) AS count
            FROM #{reflection.klass.table_name}
            GROUP BY #{foreign_key}
          ) AS #{column_name}___inner
            ON #{column_name}___inner.#{foreign_key} = #{primary_key}
        SQL
        sql = "#{column_name}___inner.count"
      else
        t = reflection.class.to_s.demodulize.gsub(/Reflection/, '')
        raise Kaprella::Errors::RelationshipTypeError.new(relationship, t)
      end

      return scope, sql
    end
  end

  rule :string, /"(?:[^"\\]|\\(?:["\\]))*"/ do
    def evaluate(scope)
      str = self.text[1...-1].gsub(/\\("|\\)/, '\1')
      return scope, ActiveRecord::Base.connection.quote(str)
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
