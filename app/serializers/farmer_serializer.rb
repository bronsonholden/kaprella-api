class FarmerSerializer < ApplicationSerializer
  attribute :name
  attribute :created_at
  attribute :updated_at

  has_many :fields

  def meta
    (super || {}).merge({
      'fieldCount' => object.fields.length,
      'fieldsTotalArea' => object.fields.sum('st_area("boundary")')
    })
  end
end
