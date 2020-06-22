class PlantVarietySerializer < ApplicationSerializer
  attribute :genus
  attribute :denomination
  attribute :created_at
  attribute :updated_at
  attribute :trademark do
    trademark_name = object.trademark_name
    trademark_name && trademark_name.mark
  end
end
