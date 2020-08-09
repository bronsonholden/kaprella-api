class FarmerSerializer < ApplicationSerializer
  attribute :name
  attribute :created_at
  attribute :updated_at

  has_many :fields

  def meta
    (super || {}).merge({
      'fieldsCount' => object.fields_count,
      'fieldsArea' => object.fields_area
    })
  end
end
