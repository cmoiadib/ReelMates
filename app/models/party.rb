require "open-uri"
require "json"

class Party < ApplicationRecord
  belongs_to :admin, class_name: 'User', foreign_key: 'user_id'
  has_many :party_players, dependent: :destroy
  has_many :users, through: :party_players
  has_many :swipes, through: :party_players

  after_update :assign_movies!, if: :saved_change_to_start?

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

  def assign_movies!
    all_movies = []

    for i in 1..20
      url = "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=fr-FR&watch_region=FR&page=#{i}"
      url += "&with_watch_providers=#{platform_setting.join('|')}" if platform_setting.present?
      url += "&with_genres=#{category_setting.join('|')}" if category_setting.present?
      url += "&primary_release_date.gte=#{start_year}-01-01" if start_year.present?
      url += "&primary_release_date.lte=#{end_year}-12-31" if end_year.present?
      url += "&api_key=#{ENV['TMDB_API_KEY']}"

      response = URI.open(url).read
      parsed_response = JSON.parse(response)
      all_movies = all_movies.concat(parsed_response["results"])
    end

    party_players.each do |party_player|
      selected_movies = all_movies.sample(20)
      party_player.update(movies: selected_movies)
    end

    all_player_movies = party_players.map { |player| player.movies }.flatten.map { |movie| movie["id"] }.uniq
    update(movies: all_player_movies)
  end

  def started?
    start
  end

  def movies_assigned?

  end
end
