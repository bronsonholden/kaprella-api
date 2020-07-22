class Field < ApplicationRecord
  validates :name, presence: true
  validates :boundary, presence: true
  belongs_to :farmer

  def reload
    Field.find(id)
  end

  scope :with_area, -> {
    select_append(<<-SQL)
      CASE
        WHEN fields.srid IS NULL THEN
          ST_Area(fields.boundary)
        ELSE
          ST_Area(ST_Transform(fields.boundary::geometry, fields.srid))
      END AS "boundary_area"
    SQL
  }
end
