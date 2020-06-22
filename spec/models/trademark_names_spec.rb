require 'rails_helper'

RSpec.describe TrademarkName, type: :model do
  let(:trademark_name) { create :trademark_name }

  it 'has a subject' do
    expect(trademark_name.subject).to be_a(PlantVariety)
  end
end
