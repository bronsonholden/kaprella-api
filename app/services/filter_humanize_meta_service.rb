# Generates humanized expressions representing various filter expressions
# to be displayed in the web application.
#
# TODO: Avoid using Keisan to parse expression and generate AST twice. This
#       is done in the query service as well.
class FilterHumanizeMetaService
  attr_reader :model, :filters

  def initialize(model, filters)
    @model = model
    @filters = filters || []
  end

  def generate
    meta = {}
    filters.each { |filter|
      meta[filter] = humanize_filter(filter)
    }
    meta
  end

  protected

  def humanize_filter(filter)
    ast = Keisan::Calculator.new.ast(filter)
    return humanize_ast(ast)
  end

  def humanize_function(ast)
    case ast.name
    when 'prop'
      if ast.children.first.is_a?(Keisan::AST::String)
        model.pretty_name(ast.children.first.value)
      else
        nil
      end
    when 'is_even'
      name = humanize_ast(ast.children.first)
      "#{name} is even"
    when 'is_odd'
      name = humanize_ast(ast.children.first)
      "#{name} is odd"
    when 'lookup_s', 'lookup_i', 'lookup_b', 'lookup_f'
      reflection = model.reflections.fetch(humanize_ast(ast.children.first))
      prop = humanize_ast(ast.children.second)
      if !reflection.nil?
        "#{reflection.klass.model_name.human} #{prop}"
      end
    end
  end

  def humanize_comparator(ast)
    case ast
    when Keisan::AST::LogicalEqual
      operator = '=='
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
    else
      return nil
    end

    lval = humanize_ast(ast.children.first)
    rval = humanize_ast(ast.children.second)

    return if lval.nil? || rval.nil?

    "#{lval} #{operator} #{rval}"
  end

  def humanize_ast(ast)
    case ast
    when Keisan::AST::LogicalOperator
      humanize_comparator(ast)
    when Keisan::AST::Function
      humanize_function(ast)
    when Keisan::AST::String
      ast.value
    when Keisan::AST::Number
      ast.value.to_s
    when Keisan::AST::Boolean
      ast.value.to_s
    else
      nil
    end
  end
end
