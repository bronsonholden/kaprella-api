class Patent < ApplicationRecord
  validates :patent_number, presence: true
  validates :title, presence: true
  validates :expiration_date, presence: true
  validates :authority, presence: true
  validates :assignee, presence: true
  validates :subject_id, presence: true, uniqueness: true

  belongs_to :assignee, class_name: 'Licensor'
  belongs_to :subject, class_name: 'PlantVariety'
end
