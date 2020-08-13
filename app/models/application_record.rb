class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.pretty_name(attribute)
    if attribute == 'id'
      return 'ID'
    else
      attribute.humanize
    end
  end

  # Accessor for class generated columns
  class << self
    attr_writer :generated_columns
    def generated_columns
      @generated_columns ||= []
    end
  end

  # Wrapper for scope() that captures metadata for the reflection API.
  # Passing nil as the sql_type will exclude it from the reflection metadata,
  # e.g. when executing a join to be used by other scopes. In this case,
  # ensure the dependent scope bodies call the "parent" scope. See Farmer's
  # generated column `fields_count` for an example.
  def self.generated_column(name, sql_type, body)
    generated_columns << {
      name: name.to_sym,
      sql_type: sql_type
    }
    self.scope name, body
  end

  # Scope that includes all generated columns.
  scope :with_generated_columns, -> {
    scope = all
    generated_columns.each { |col|
      scope = scope.send(col[:name])
    }
    scope
  }
end
