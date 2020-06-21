class FieldRealizer < ApplicationRealizer
  type :field, class_name: 'Field', adapter: :active_record
  has :name
  has :srid
  has :boundary
  has_one :farmer, class_name: 'FarmerRealizer'
end
