class Field < ApplicationRecord
  PRETTY_NAMES = {
    'farmer_id' => 'Farmer ID',
    'srid' => 'SRID'
  }.freeze

  validates :name, presence: true
  validates :boundary, presence: true
  belongs_to :farmer, -> { Farmer.with_field_totals }

  def self.pretty_name(attribute)
    PRETTY_NAMES[attribute] || super
  end

  def reload
    Field.find(id)
  end

  scope :with_geo, -> {
    select_append(<<-SQL
      CASE
        WHEN fields.srid IS NULL THEN
          ST_Area(fields.boundary)
        ELSE
          ST_Area(ST_Transform(fields.boundary::geometry, fields.srid))
      END AS "boundary_area"
    SQL
    ).select_append(<<-SQL
      ST_Centroid(fields.boundary) AS "centroid"
    SQL
    )
  }
end
