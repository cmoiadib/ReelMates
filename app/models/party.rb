class Party < ApplicationRecord
  belongs_to :admin, class_name: 'User', foreign_key: 'user_id'
  has_many :party_players, dependent: :destroy
  has_many :users, through: :party_players
  has_many :swipes, through: :party_players

  PROVIDERS = [ "Netflix", "Prime", "HBO", "OCS", "Apple TV+", "Disney+"]
end
