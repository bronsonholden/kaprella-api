# A Licensee is an organization that is licensed to grow, market, or
# propagate fruit breeds owned by IFG.
class Licensee < ApplicationRecord
  validates :name, presence: true
  validates :account_id, uniqueness: true, presence: true
  validates :country, presence: true
  auto_increment :account_id, initial: 3000, before: :validation, lock: true

  # The account number uniquely identifies a Licensee, but historically it is
  # formatted with a prefixed 'A'.
  def account_number
    "A%04d" % account_id
  end
end
