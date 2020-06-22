class TrademarkNameRealizer < ApplicationRealizer
  type :trademark_name, class_name: 'TrademarkName', adapter: :active_record
  has :authority
  has :title
  has :mark
  has :grant_date
  has :renewal_date
  has_one :subject, class_name: 'PlantVarietyRealizer'
end
