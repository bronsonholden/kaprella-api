class Farmer < ApplicationRecord
  validates :name, presence: true
  has_many :fields

  scope :with_field_totals, -> {
    includes(:fields).joins(<<-SQL
      join (
        select farmers.id as farmer_id, count(fields.id) as count, sum(st_area(fields.boundary)) as area
        from farmers join fields on fields.farmer_id = farmers.id
        group by farmers.id
      ) as totals on totals.farmer_id = farmers.id
      SQL
    ).select_append('totals.count as fields_count, totals.area as fields_area')
  }
end
