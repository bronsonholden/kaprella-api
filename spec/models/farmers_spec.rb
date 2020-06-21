require 'rails_helper'

RSpec.describe Farmer, type: :model do
  let(:farmer) { create :farmer }

  it 'has fields' do
    5.times { create :field, farmer: farmer }
    expect(farmer.fields).to all(be_a(Field))
  end
end
