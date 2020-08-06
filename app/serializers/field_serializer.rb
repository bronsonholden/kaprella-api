class FieldSerializer < ApplicationSerializer
  attribute :name
  attribute :srid
  attribute :created_at
  attribute :updated_at

  attribute :boundary do
    if object.boundary.is_a?(String)
      object.boundary
    else
      object.boundary.as_text
    end
  end

  attribute :area do
    object.boundary_area
  end

  attribute :centroid do
    object.centroid
  end

  has_one :farmer
end
