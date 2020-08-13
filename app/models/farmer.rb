class Farmer < ApplicationRecord
  validates :name, presence: true
  has_many :fields

  generated_column :with_field_totals, nil, -> {
    joins(<<-SQL
      left join (
        select
          farmers.id as farmer_id,
          count(fields.id) as count,
          sum(st_area(fields.boundary)) as area
        from farmers join fields on fields.farmer_id = farmers.id
        group by farmers.id
      ) as field_totals on field_totals.farmer_id = farmers.id
      SQL
    )
  }

  generated_column :fields_count, 'integer', -> {
    with_field_totals.select_append('coalesce(field_totals.count, 0) as fields_count')
  }

  generated_column :fields_area, 'decimal', -> {
    with_field_totals.select_append('coalesce(field_totals.area, 0) as fields_area')
  }
end
