FactoryBot.define do
  factory :field do
    association :farmer, factory: :farmer
    name { 'A-1' }
    srid { }
    boundary { 'MULTIPOLYGON (((-119.189632 35.091291, -119.181226 35.091291, -119.181058 35.084274, -119.189548 35.084309), (-119.187848 35.089956, -119.182938 35.090011, -119.182694 35.085903, -119.187603 35.085794)))' }
  end
end
