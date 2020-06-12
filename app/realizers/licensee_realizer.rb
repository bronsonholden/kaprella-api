class LicenseeRealizer < ApplicationRealizer
  type :licensees, class_name: 'Licensee', adapter: :active_record
  has :name
  has :country
end
