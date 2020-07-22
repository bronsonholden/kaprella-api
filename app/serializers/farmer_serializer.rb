class FarmerSerializer < ApplicationSerializer
  attribute :name
  attribute :created_at
  attribute :updated_at

  def meta
    (super || {}).merge({
      'fieldCount' => object.fields.length
    })
  end
end
