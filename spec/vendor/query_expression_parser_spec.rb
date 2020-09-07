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
  let(:generated_name) { 'generated' }
  let(:generated_scope) {
    evaluated_scope.select_append("#{evaluated_sql} as \"#{generated_name}\"")
  }

  let(:scope) { Farmer.all }

  describe 'attributes' do
    let(:expression) { 'id' }
    it 'returns attribute' do
      expect(evaluated_sql).to eq('farmers.id')
    end
  end

  describe 'relationships' do
    describe 'has many' do
      let(:scope) { Farmer.all }
      let(:farmer) { create :farmer }
      let(:count) { 10 }

      # Create some fields for testing
      before(:each) do
        count.times do
          create :field, farmer: farmer
        end
      end

      describe 'generated column' do
        let(:expression) { 'fields.count' }
        let(:value) {
          generated_scope.find(farmer.id).send(generated_name.to_sym)
        }
        it 'returns count' do
          expect(value).to eq(10)
        end
      end

      describe 'filtering' do
        # So we don't raise RecordNotFound in the 'not matching' test
        let(:record) { filtered_scope.where(id: farmer.id) }

        context 'matching' do
          let(:expression) { "fields.count == #{count}" }
          it 'returns record' do
            expect(record).to include(farmer)
          end
        end

        context 'not matching' do
          let(:expression) { "fields.count != #{count}" }
          it 'returns no record' do
            expect(record).not_to include(farmer)
          end
        end
      end
    end

    describe 'belongs to' do
      let(:scope) { Field.all }
      let(:expression) { 'farmer.name' }
      let(:farmer) { create :farmer }
      let(:field) { create :field, farmer: farmer }
      let(:value) {
        generated_scope.find(field.id).send(generated_name.to_sym)
      }
      it 'returns attribute' do
        expect(value).to eq(farmer.name)
      end
    end
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
