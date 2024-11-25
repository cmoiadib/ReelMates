class PartyPlayer < ApplicationRecord
  belongs_to :party_id
  belongs_to :user_id
end
