require 'rails_helper'

RSpec.describe Field, type: :model do
  let(:field) { create :field }

  it 'has a farmer' do
    expect(field.farmer).to be_a(Farmer)
  end
end
