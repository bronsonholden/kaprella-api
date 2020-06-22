require 'rails_helper'

RSpec.describe Patent, type: :model do
  let(:patent) { create :patent }

  it 'has a subject' do
    expect(patent.subject).to be_a(PlantVariety)
  end
end
