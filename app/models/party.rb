class Party < ApplicationRecord
  belongs_to :admin, class_name: 'User', foreign_key: 'user_id'
  has_many :party_players, dependent: :destroy
  has_many :users, through: :party_players
  has_many :swipes, through: :party_players

  PROVIDERS = [
    { name: "Netflix", id: "8" },
    { name: "Prime", id: "119" },
    { name: "Apple TV+", id: "350" },
    { name: "Disney+", id: "337" }
  ]

  GENRES = [
    { name: "Action", id: 28 },
    { name: "Adventure", id: 12 },
    { name: "Animation", id: 16 },
    { name: "Comedy", id: 35 },
    { name: "Crime", id: 80 },
    { name: "Documentary", id: 99 },
    { name: "Drama", id: 18 },
    { name: "Family", id: 10751 },
    { name: "Fantasy", id: 14 },
    { name: "History", id: 36 },
    { name: "Horror", id: 27 },
    { name: "Music", id: 10402 },
    { name: "Mystery", id: 9648 },
    { name: "Romance", id: 10749 },
    { name: "Science Fiction", id: 878 },
    { name: "TV Movie", id: 10770 },
    { name: "Thriller", id: 53 },
    { name: "War", id: 10752 },
    { name: "Western", id: 37 }
  ]

  def platform_setting=(values)
    super(Array(values))
  end

  def category_setting=(values)
    super(Array(values))
  end
end
