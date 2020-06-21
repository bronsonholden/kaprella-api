class Licensor < ApplicationRecord
  validates :name, presence: true
  has_many :patents
end
