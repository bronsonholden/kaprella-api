class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true

  def self.pretty_name(attribute)
    if attribute == 'id'
      return 'ID'
    else
      attribute.humanize
    end
  end
end
