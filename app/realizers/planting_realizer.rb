class PlantingRealizer < ApplicationRealizer
  type :planting, class_name: 'Planting', adapter: :active_record
  has :notes
  has :active
  has_one :field, class_name: 'FieldRealizer'
end
