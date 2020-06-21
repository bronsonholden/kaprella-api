class PatentSerializer < ApplicationSerializer
  attribute :title
  attribute :patent_number
  attribute :expiration_date
  attribute :authority
  attribute :created_at
  attribute :updated_at
end
