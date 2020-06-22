FactoryBot.define do
  factory :plant_variety do
    genus { 'Vitis' }
    denomination { 'Kaprella Imaginarium One' }
  end

  factory :trademark_protected_plant_variety, parent: :plant_variety do
    association :trademark_name, factory: :trademark_name
  end
end
