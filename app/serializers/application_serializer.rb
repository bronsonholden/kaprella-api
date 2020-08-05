class ApplicationSerializer
  include JSONAPI::Serializer

  def base_url
    opts = Rails.application.routes.default_url_options
    "#{opts[:protocol]}://#{opts[:host]}"
  end

  def meta
    virtual_columns = object.attributes.keys - object.class.column_names
    if virtual_columns.any?
      meta = {}
      virtual_columns.map(&:to_sym).each { |col|
        meta[format_name(col)] = object.send(col)
      }
      meta
    else
      nil
    end
  end

  def type
    object.model_name.plural.camelize(:lower)
  end

  def format_name(attribute)
    attribute.to_s.camelize(:lower)
  end

  def unformat_name(attribute)
    attribute.underscore
  end
end
