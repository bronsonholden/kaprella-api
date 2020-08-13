class ReflectionMetaService
  attr_reader :model

  def initialize(model)
    @model = model
  end

  def columns
    model.columns_hash
  end

  def relationships
    model.reflections
  end

  def generate
    {
      'attributes' => columns.map { |name, column|
        [ name.camelize(:lower), serialize_column(column) ]
      }.to_h,
      'relationships' => relationships.map { |name, relationship|
        [ name.camelize(:lower), serialize_relationship(relationship) ]
      }.to_h,
      'generated' => model.generated_columns.reject { |column|
        column[:sql_type].nil?
      }.map { |column|
        [ column[:name].to_s.camelize(:lower), serialize_generated_column(column) ]
      }.to_h
    }
  end

  private

  def serialize_column(column)
    {
      'sqlTypeMetadata' => sql_type_metadata_json(column.sql_type_metadata),
      'defaultValue' => column.default,
      'allowNull' => column.null,
      'comment' => column.comment,
      'name' => column.name,
      'prettyName' => model.pretty_name(column.name)
    }
  end

  def serialize_relationship(relationship)
    {
      'relationshipType' => relationship_type_name(relationship),
      'resource' => relationship.class_name,
      'foreignKey' => relationship.foreign_key,
      'options' => relationship.options,
      'name' => relationship.name.to_s,
      'prettyName' => model.pretty_name(relationship.name.to_s)
    }
  end

  def serialize_generated_column(column)
    {
      'sqlTypeMetadata' => {
        'type' => column[:sql_type]
      },
      'prettyName' => model.pretty_name(column[:name].to_s)
    }
  end

  def relationship_type_name(r)
    r.class.to_s.split('::').last.gsub(/Reflection$/, '').camelize(:lower)
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
