FactoryBot.define do
  factory :patent do
    association :assignee, factory: :licensor
    association :subject, factory: :plant_variety
    authority { 'Fictitious Patent Office' }
    patent_number { 'P012345' }
    title { 'Kaprella' }
    expiration_date { Date.today + 1.year }
  end
end
