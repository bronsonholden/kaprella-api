class PlantVarietyRealizer < ApplicationRealizer
  type :plant_variety, class_name: 'PlantVariety', adapter: :active_record
  has :genus
  has :denomination
end
