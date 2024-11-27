class PartyPlayer < ApplicationRecord
  belongs_to :party
  belongs_to :user

  validates :user_id, uniqueness: { scope: :party_id, message: "is already in this party" }
end
