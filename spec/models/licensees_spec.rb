require 'rails_helper'

RSpec.describe Licensee, type: :model do
  describe 'account number' do
    let(:account_id) { nil }
    let(:licensee) { create :licensee, account_id: account_id }

    shared_examples 'valid_account_number' do
      # Licensee account numbers should match IFG's historical format of:
      # A0000 where the number portion is padded to a width of at least 4.
      # Numbers larger than this width will simply extend to as many
      # characters as is needed.
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
