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

  describe 'evaluated' do
    let(:scope) { Farmer.all }
    let(:generated_value) {
      generated_scope.first.send(generated_name.to_sym)
    }

    describe 'literals' do
      before(:each) do
        create :farmer
      end

      describe 'numbers' do
        {
          '1' => 1,
          '1e2' => 100,
          '-5.3' => -5.3
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end

      describe 'strings' do
        [
          'abcd',
          'abc"',
          'abcdef\\',
          'Æ'
        ].each do |str|
          context str do
            let(:expression) { str.inspect }
            it 'returns value' do
              expect(generated_value).to eq(str)
            end
          end
        end
      end
    end

    describe 'arithmetic' do
      before(:each) do
        create :farmer
      end

      describe '+' do
        {
          '1 + 2 + 3' => 6,
          '(1 + 2) + 3' => 6,
          '1 + (2 + 3)' => 6
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
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
              expect(generated_value).to eq(value)
            end
          end
        end
      end

      describe '*' do
        {
          '1 * 2 * 3' => 6,
          '(1 * 2) * 3' => 6,
          '1 * (2 * 3)' => 6
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end

      describe '/' do
        {
          '10 / 5 / 2' => 1,
          '(10 / 5) / 2' => 1,
          '10 / (20 / 2)' => 1
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end
    end

    describe 'boolean expressions' do
      before(:each) do
        create :farmer
      end

      describe '<' do
        {
          '1 < 2' => true,
          '2 < 1' => false,
          '1 < (1 + 1)' => true
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end

      describe '<=' do
        {
          '1 <= 2' => true,
          '1 <= 1' => true,
          '2 <= 1' => false,
          '1 <= (1 + 1)' => true,
          '1 <= (0 + 1)' => true
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end

      describe '>' do
        {
          '1 > 2' => false,
          '2 > 1' => true,
          '1 > (1 + 1)' => false,
          '2 > (0 + 1)' => true
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end

      describe '>=' do
        {
          '1 >= 2' => false,
          '1 >= 1' => true,
          '2 >= 1' => true,
          '1 >= (1 + 1)' => false,
          '2 >= (1 + 1)' => true
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end

      describe '==' do
        {
          '1 == 2' => false,
          '1 == 1' => true,
          '1 == (1 + 1)' => false,
          '2 == (1 + 1)' => true
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end

      describe '!=' do
        {
          '1 != 2' => true,
          '1 != 1' => false,
          '1 != (1 + 1)' => true,
          '2 != (1 + 1)' => false
        }.each do |expr, value|
          context expr do
            let(:expression) { expr }
            it 'returns value' do
              expect(generated_value).to eq(value)
            end
          end
        end
      end
    end

    describe 'attribute' do
      let(:scope) { Farmer.all }
      let(:farmer_name) { 'ACME Farmer' }
      let(:generated_value) {
        generated_scope.first.send(generated_name.to_sym)
      }
      let(:expression) { 'name' }
      before(:each) do
        create :farmer, name: farmer_name
      end

      it 'returns attribute' do
        expect(generated_value).to eq(farmer_name)
      end
    end

    describe 'related attribute' do
      let(:scope) { Field.all }
      let(:generated_value) {
        generated_scope.first.send(generated_name.to_sym)
      }
      let(:farmer_name) { 'ACME Farmer' }
      let(:expression) { 'farmer.name' }
      let(:farmer) { create :farmer, name: farmer_name }
      before(:each) do
        create :field, farmer: farmer
      end
      it 'returns attribute' do
        expect(generated_value).to eq(farmer_name)
      end
    end

    describe 'related count' do
      let(:scope) { Farmer.all }
      let(:generated_value) {
        generated_scope.first.send(generated_name.to_sym)
      }
      let(:farmer_name) { 'ACME Farmer' }
      let(:expression) { 'fields.count' }
      let(:farmer) { create :farmer, name: farmer_name }
      let(:count) { 10 }
      before(:each) do
        count.times do
          create :field, farmer: farmer
        end
      end
      it 'returns attribute' do
        expect(generated_value).to eq(count)
      end
    end
  end
end
