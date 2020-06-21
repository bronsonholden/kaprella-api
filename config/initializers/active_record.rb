module ActiveRecord
  class Relation
    def select_append(*fields)
      fields.unshift(arel_table[Arel.star]) if !select_values.any?
      select(*fields)
    end
  end
end
