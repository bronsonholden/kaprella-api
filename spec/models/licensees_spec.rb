require 'rails_helper'

RSpec.describe Licensee, type: :model do
  describe 'validations' do
    let(:account_id) { nil }
    let(:licensee) { create :licensee, account_id: account_id }

    shared_examples 'valid_account_number' do
      it 'has a valid Account Number format' do
        expect(licensee.account_number).to match(/\AA\d{4,}\z/)
      end
    end

    context '< 4 digits' do
      let(:account_id) { 1 }
      include_examples 'valid_account_number'
    end

    context '= 4 digits' do
      let(:account_id) { 1234 }
      include_examples 'valid_account_number'
    end

    context '> 4 digits' do
      let(:account_id) { 12345 }
      include_examples 'valid_account_number'
    end
  end
end
