class TrademarkNameSerializer < ApplicationSerializer
  attribute :authority
  attribute :title
  attribute :mark
  attribute :grant_date
  attribute :renewal_date
  attribute :created_at
  attribute :updated_at
end
