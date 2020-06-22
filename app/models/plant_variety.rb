class PlantVariety < ApplicationRecord
  validates :genus, presence: true
  validates :denomination, presence: true
  has_one :patent, class_name: 'Patent', foreign_key: 'subject_id'
  has_one :trademark_name, class_name: 'TrademarkName', foreign_key: 'subject_id'

  scope :with_protections, -> {
    includes(:patent, :trademark_name)
  }
end
