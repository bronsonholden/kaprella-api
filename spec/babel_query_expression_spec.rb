require 'rails_helper'

RSpec.describe BabelQueryExpressionParser do
  let(:parser) { BabelQueryExpressionParser.new }
  let(:evaluated) {
    r = parser.parse(expression)
    if r.nil?
      raise parser.parser_failure_info
    else
      r.evaluate(scope)
    end
  }
  let(:evaluated_scope) { evaluated[0] }
  let(:evaluated_sql) { evaluated[1] }
  let(:filtered_scope) { evaluated_scope.where(evaluated_sql) }
  let(:generated_name) { 'generated' }
  let(:generated_scope) {
    evaluated_scope.select_append("#{evaluated_sql} as \"#{generated_name}\"")
  }

  let(:scope) { Farmer.all }

  describe 'literals' do
    describe 'numbers' do
      let(:expression) { '1' }
      it 'returns value' do
        expect(evaluated).not_to be_nil
      end
    end

    describe 'strings' do
      let(:expression) { '"str"' }
      it 'returns value' do
        expect(evaluated).not_to be_nil
      end
    end
  end

  describe 'arithmetic' do
    before(:each) do
      create :farmer
    end

    describe '+' do
      [
        '1 + 2 + 3',
        '(1 + 2) + 3',
        '1 + (2 + 3)'
      ].each do |expr|
        context expr do
          let(:expression) { expr }
          it 'returns value' do
            expect(generated_scope.first.send(generated_name.to_sym)).to eq(6)
          end
        end
      end
    end

    describe '-' do
      {
        '1 - 2 - 3' => -4,
        '(1 - 2) - 3' => -4,
        '1 - (2 - 3)' => 2
      }.each do |expr, value|
        context expr do
          let(:expression) { expr }
          it 'returns value' do
            expect(generated_scope.first.send(generated_name.to_sym)).to eq(value)
          end
        end
      end
    end
  end

  describe 'boolean expressions' do
    before(:each) do
      Farmer.create(name: 'Test Farmer')
    end

    shared_examples 'contains_results' do
      it 'returns result' do
        expect(filtered_scope.size).to eq(1)
      end
    end

    shared_examples 'contains_no_results' do
      it 'returns no result' do
        expect(filtered_scope.size).to eq(0)
      end
    end

    describe '<' do
      context 'truthy' do
        let(:expression) { '1 < 2' }
        include_examples 'contains_results'
      end

      context 'falsey' do
        let(:expression) { '2 < 1' }
        include_examples 'contains_no_results'
      end
    end

    describe '>' do
      context 'truthy' do
        let(:expression) { '2 > 1' }
        include_examples 'contains_results'
      end

      context 'falsey' do
        let(:expression) { '1 > 2' }
        include_examples 'contains_no_results'
      end
    end

    describe '<=' do
      context 'truthy' do
        let(:expression) { '2 <= 2' }
        include_examples 'contains_results'
      end

      context 'falsey' do
        let(:expression) { '2 <= 1' }
        include_examples 'contains_no_results'
      end
    end

    describe '>=' do
      context 'truthy' do
        let(:expression) { '2 >= 2' }
        include_examples 'contains_results'
      end

      context 'falsey' do
        let(:expression) { '1 >= 2' }
        include_examples 'contains_no_results'
      end
    end

    describe '==' do
      context 'truthy' do
        let(:expression) { '1 == 1' }
        include_examples 'contains_results'
      end

      context 'falsey' do
        let(:expression) { '1 == 2' }
        include_examples 'contains_no_results'
      end
    end

    describe '!=' do
      context 'truthy' do
        let(:expression) { '1 != 2' }
        include_examples 'contains_results'
      end

      context 'falsey' do
        let(:expression) { '1 != 1' }
        include_examples 'contains_no_results'
      end
    end
  end
end
