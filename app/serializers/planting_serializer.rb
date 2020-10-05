class PlantingSerializer < ApplicationSerializer
  attribute :notes
  attribute :active
  attribute :created_at
  attribute :updated_at
  has_one :field
end
