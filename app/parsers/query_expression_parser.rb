class QueryExpressionParser < Parslet::Parser
  root(:expression)

  rule(:expression) {
    space? >> lparen >> space? >> operation.as(:body) >> rparen >> space?
  }

  rule(:atom) { expression | literal | related_attribute | attribute }

  rule(:space)  { match('\s').repeat(1) }
  rule(:space?) { space.maybe }
  rule(:lparen) { str('(') >> space? }
  rule(:rparen) { str(')') >> space? }

  rule(:digit) { match('[0-9]') }
  rule(:number) {
    (
      str('-').maybe >> (
        str('0') | (match('[1-9]') >> digit.repeat)
      ) >> (
        str('.') >> digit.repeat(1)
      ).maybe >> (
        match('[eE]') >> (str('+') | str('-')).maybe >> digit.repeat(1)
      ).maybe
    ).as(:number) >> space?
  }

  rule(:string) {
    str('"') >> (
      str('\\') >> any | str('"').absent? >> any
    ).repeat.as(:string) >> str('"') >> space?
  }

  rule(:mul_op) { match['*/'].as(:infix_op) >> space? }
  rule(:add_op) { match['+-'].as(:infix_op) >> space? }
  rule(:lt) { str('<') }
  rule(:le) { str('<=') }
  rule(:gt) { str('>') }
  rule(:ge) { str('>=') }
  rule(:eq) { str('==') }
  rule(:ne) { str('!=') }
  rule(:logic_op) { (le | ge | lt | gt | eq | ne).as(:infix_op) >> space? }
  rule(:infix_op) { (mul_op | add_op | logic_op).as(:infix_op) }

  rule(:operation) {
    infix_expression(
      atom,
      [mul_op, 3, :left],
      [add_op, 2, :right],
      [logic_op, 1, :left]
    ) >> space?
  }

  rule(:related_attribute) { match('[a-zA-Z]').repeat.as(:relationship) >> str('.') >> match('[a-zA-Z]').repeat.as(:attribute) >> space? }
  rule(:attribute) { match('[a-zA-Z]').repeat.as(:attribute) >> space? }

  rule(:literal) { number | string}
end
