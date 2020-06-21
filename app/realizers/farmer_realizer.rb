class FarmerRealizer < ApplicationRealizer
  type :farmer, class_name: 'Farmer', adapter: :active_record
  has :name
  has_many :fields, class_name: 'FieldRealizer'
end
