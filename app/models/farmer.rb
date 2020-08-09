class Farmer < ApplicationRecord
  validates :name, presence: true
  has_many :fields

  scope :with_field_totals, -> {
    includes(:fields).joins(<<-SQL
      left join (
        select farmers.id as farmer_id, count(fields.id) as count, sum(st_area(fields.boundary)) as area
        from farmers join fields on fields.farmer_id = farmers.id
        group by farmers.id
      ) as totals on totals.farmer_id = farmers.id
      SQL
    ).select_append('coalesce(totals.count, 0) as fields_count, coalesce(totals.area, 0) as fields_area')
  }
end
