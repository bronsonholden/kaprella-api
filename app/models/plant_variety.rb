class PlantVariety < ApplicationRecord
  validates :genus, presence: true
  validates :denomination, presence: true
  has_one :patent
end
