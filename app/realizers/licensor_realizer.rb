class LicensorRealizer < ApplicationRealizer
  type :licensor, class_name: 'Licensor', adapter: :active_record
  has :name
end
