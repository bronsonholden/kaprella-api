class Farmer < ApplicationRecord
  validates :name, presence: true
  has_many :fields
end
