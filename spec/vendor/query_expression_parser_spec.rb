require 'rails_helper'

RSpec.describe QueryExpressionParser do
  let(:parser) { QueryExpressionParser.new }
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

  let(:scope) { Farmer.all }

  describe 'attributes' do
    let(:expression) { 'id' }
    it 'returns attribute' do
      expect(evaluated_sql).to eq('farmers.id')
    end
  end

  describe 'relationships' do
  end

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
