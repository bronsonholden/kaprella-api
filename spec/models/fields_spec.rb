require 'rails_helper'

RSpec.describe Field, type: :model do
  let(:field) { create :field }

  it 'has a farmer' do
    expect(field.farmer).to be_a(Farmer)
  end

  it 'has an area' do
    # The factory-returned object won't have the generated boundary area
    # column, so we have to run an ActiveRecord query that will return it
    # as part of the default scope for Fields.
    expect(Field.with_geo.find(field.id).boundary_area).to be_a(Numeric)
  end
end
