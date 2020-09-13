require 'rails_helper'

RSpec.describe 'Query expression' do
  let(:parser) { QueryExpressionParser.new }
  let(:transform) { QueryExpressionTransform.new }
  let(:ast) { parser.parse("(#{expression})") }
  let(:scope) { Farmer.all }
  let(:context) {
    {
      scope: scope
    }
  }
  # Remove outer parens
  let(:sql) { transform.apply(ast, context: context)[1...-1] }
  let(:evaluated_scope) {
    sql
    context[:scope]
  }

  describe 'SQL' do
    describe 'attributes' do
      let(:expression) { 'createdAt' }
      it 'parses expression' do
        expect(sql).to eq('farmers.created_at')
      end
    end

    describe 'related attributes' do
      let(:scope) { Field.all }
      let(:expression) { 'farmer.name' }
      it 'parses expression' do
        expect(sql).to eq('farmers.name')
      end
    end

    describe 'literals' do
      describe 'number' do
        let(:expression) { '100' }
        it 'parses number literal' do
          expect(sql).to eq('100')
        end
        context 'parenthetical' do
          let(:expression) { "(100)" }
          it 'parses number literal' do
            expect(sql).to eq('(100)')
          end
        end
      end

      describe 'string' do
        let(:expression) { '"str"' }
        it 'parses string literal' do
          expect(sql).to eq("'str'")
        end
      end
    end

    describe 'infix expressions' do
      describe 'arithmetic' do
        describe '+' do
          let(:expression) { '1 + 2' }
          it 'parses expression' do
            expect(sql).to eq('1 + 2')
          end
        end

        describe '-' do
          let(:expression) { '1 - 2' }
          it 'parses expression' do
            expect(sql).to eq('1 - 2')
          end
        end

        describe '*' do
          let(:expression) { '1 * 2' }
          it 'parses expression' do
            expect(sql).to eq('1 * 2')
          end
        end

        describe '/' do
          let(:expression) { '1 / 2' }
          it 'parses expression' do
            expect(sql).to eq('1 / 2')
          end
        end
      end

      describe 'logical' do
        describe '>' do
          let(:expression) { '1 > 2' }
          it 'parses expression' do
            expect(sql).to eq('1 > 2')
          end
        end

        describe '>=' do
          let(:expression) { '1 >= 2' }
          it 'parses expression' do
            expect(sql).to eq('1 >= 2')
          end
        end

        describe '<' do
          let(:expression) { '1 < 2' }
          it 'parses expression' do
            expect(sql).to eq('1 < 2')
          end
        end

        describe '<=' do
          let(:expression) { '1 <= 2' }
          it 'parses expression' do
            expect(sql).to eq('1 <= 2')
          end
        end

        describe '==' do
          let(:expression) { '1 == 2' }
          it 'parses expression' do
            expect(sql).to eq('1 == 2')
          end
        end

        describe '!=' do
          let(:expression) { '1 != 2' }
          it 'parses expression' do
            expect(sql).to eq('1 != 2')
          end
        end
      end

      context 'nested' do
        let(:expression) { '(1 + 2) * 3' }
        it 'parses expression' do
          expect(sql).to eq('(1 + 2) * 3')
        end
      end
    end
  end

  describe 'execution' do
    let(:generated_column) { 'generated' }
    let(:generated_scope) {
      evaluated_scope.select_append("#{sql} as \"#{generated_column}\"")
    }
    let(:generated_value) {
      generated_record.send(generated_column.to_sym)
    }

    describe 'attributes' do
      let(:farmer_name) { 'ACME Farmers' }
      let(:expression) { 'name' }
      let(:farmer) { create :farmer, name: farmer_name }
      let(:generated_record) { generated_scope.first }

      before(:each) do
        create :farmer, name: farmer_name
      end

      it 'returns attribute' do
        expect(generated_value).to eq(farmer_name)
      end
    end

    describe 'related attributes' do
      let(:farmer_name) { 'ACME Farmers' }
      let(:expression) { 'farmer.name' }
      let(:scope) { Field.all }
      let(:farmer) { create :farmer, name: farmer_name }
      let(:generated_record) { generated_scope.first }

      before(:each) do
        create :field, farmer: farmer
      end

      it 'returns attribute' do
        expect(generated_value).to eq(farmer_name)
      end
    end

    describe 'related count' do
      let(:expression) { 'fields.count' }
      let(:generated_record) { generated_scope.first }
      let(:farmer) { create :farmer }
      let(:count) { 10 }
      before(:each) do
        count.times do
          create :field, farmer: farmer
        end
      end

      it 'returns count' do
        expect(generated_value).to eq(count)
      end
    end

    describe 'literals' do
      before(:each) do create :farmer; end
      let(:generated_record) { generated_scope.first }

      describe 'numbers' do
        [
          '1',
          '1.0',
          '1e0',
          '10E-1'
        ].each { |i|
          context i do
            let(:expression) { i }
            it 'returns value' do
              expect(generated_value).to eq(1)
            end
          end
        }
      end

      describe 'strings' do
        [
          'abcd',
          'my string"',
          '\'string\''
        ].each { |s|
          context s do
            let(:expression) { "\"#{s.gsub('"', '\"')}\"" }
            it 'returns value' do
              expect(generated_value).to eq(s)
            end
          end
        }
      end
    end
  end
end
