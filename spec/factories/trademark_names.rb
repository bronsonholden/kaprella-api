FactoryBot.define do
  factory :trademark_name do
    association :subject, factory: :plant_variety
    mark { 'Greatfruit' }
    title { 'Greatfruit' }
    authority { 'Fictitious Patent Office' }
    grant_date { Date.today }
    renewal_date { Date.today + 10.years }
  end
end
