class FieldSerializer < ApplicationSerializer
  attribute :name
  attribute :srid
  attribute :boundary
  attribute :created_at
  attribute :updated_at

  attribute :area do
    object.boundary_area
  end

  has_one :farmer
end
