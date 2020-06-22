require 'rails_helper'

RSpec.describe PlantVariety, type: :model do
  context 'trademark protected' do
    let(:plant_variety) { create :trademark_protected_plant_variety }

    it 'has a trademark name' do
      expect(plant_variety.trademark_name).to be_a(TrademarkName)
    end
  end
end
