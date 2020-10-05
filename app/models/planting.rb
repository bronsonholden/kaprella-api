class Planting < ApplicationRecord
  validates :active, presence: true
  validates :field_id, presence: true

  belongs_to :field, class_name: 'Field'
end
