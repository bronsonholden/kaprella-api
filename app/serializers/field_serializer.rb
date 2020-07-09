class FieldSerializer < ApplicationSerializer
  attribute :name
  attribute :srid
  attribute :boundary do object.boundary.as_text; end
  attribute :created_at
  attribute :updated_at

  attribute :area do
    object.boundary_area
  end
end
