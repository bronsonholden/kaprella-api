class PatentRealizer < ApplicationRealizer
  type :patent, class_name: 'Patent', adapter: :active_record
  has :title
  has :patent_number
  has :expiration_date
  has :authority
  has_one :assignee, class_name: 'LicensorRealizer'
  has_one :subject, class_name: 'PlantVarietyRealizer'
end
