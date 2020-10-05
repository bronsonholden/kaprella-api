FactoryBot.define do
  factory :planting do
    notes { 'Some notes' }
    active { true }
    association :field, factory: :field
  end
end
