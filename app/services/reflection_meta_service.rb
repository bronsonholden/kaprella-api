class ReflectionMetaService
  attr_reader :columns

  def initialize(columns)
    @columns = columns
  end

  def generate
    columns.map { |name, column|
      [ name.camelize(:lower), serialize(column) ]
    }.to_h
  end

  private

  def serialize(column)
    {
      'sqlTypeMetadata' => sql_type_metadata_json(column.sql_type_metadata),
      'defaultValue' => column.default,
      'allowNull' => column.null,
      'comment' => column.comment
    }
  end

  def sql_type_metadata_json(t)
    {
      'sqlType' => t.sql_type,
      'type' => t.type,
      'limit' => t.limit,
      'precision' => t.precision,
      'scale' => t.scale
    }
  end
end
