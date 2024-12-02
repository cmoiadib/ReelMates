class PartyPlayer < ApplicationRecord
  belongs_to :party
  belongs_to :user
  has_many :swipes

  validates :user_id, uniqueness: { scope: :party_id, message: "is already in this party" }

  def done?
    total_swipes = party.swipes.count  # Count all swipes in the party
    total_movies = party.movies.count  # Count all movies in the party
    Rails.logger.debug "Total swipes: #{total_swipes}, Movie count: #{total_movies}"
    total_swipes >= total_movies
  end
end
