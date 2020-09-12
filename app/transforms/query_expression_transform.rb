# Transforms ASTs from a Parser into SQL expressions
class QueryExpressionTransform < Parslet::Transform
  rule(number: simple(:number)) { number.to_s }
  rule(string: simple(:string)) {
    ActiveRecord::Base.connection.quote(string.to_s.gsub(/\\("|\\)/, '\1'))
  }
  rule(body: simple(:body)) {
    "(#{body.to_s})"
  }
  rule(infix_op: simple(:infix_op)) {
    infix_op.to_s
  }
  rule(l: simple(:l), o: simple(:infix_op), r: simple(:r)) {
    "#{l} #{infix_op} #{r}"
  }
  rule(attribute: simple(:attribute)) {
    column_name = attribute.to_s.underscore
    "#{context[:scope].table_name}.#{column_name}"
  }
  rule(relationship: simple(:relationship), attribute: simple(:attribute)) {
    column_name = attribute.to_s.underscore
    relationship_name = relationship.to_s.underscore
    reflection = context[:scope].reflections[relationship_name]
    table_name = reflection.klass.table_name
    raise Kaprella::Errors::InvalidRelationshipError.new(relationship) if reflection.nil?
    case reflection
    when ActiveRecord::Reflection::BelongsToReflection, ActiveRecord::Reflection::HasOneReflection
      context[:scope] = context[:scope].joins(relationship_name.to_sym)
      "#{table_name}.#{column_name}"
    else
      actual_type = reflection.class.to_s.demodulize.underscore
      raise Kaprella::Errors::RelationshipTypeError.new(relationship, actual_type.gsub(/_reflection/, ''))
    end
  }
end
