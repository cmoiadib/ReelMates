class Party < ApplicationRecord
  belongs_to :admin, class_name: :PartyPlayer
  has_many :party_players
  has_many :users, through: :party_players
  has_many :swipes, through: :party_players
end
