class TrademarkName < ApplicationRecord
  validates :title, presence: true
  validates :mark, presence: true
  validates :authority, presence: true
  validates :grant_date, presence: true
  validates :renewal_date, presence: true
  belongs_to :subject, class_name: 'PlantVariety'
end
