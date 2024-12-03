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
    { name: "AppleTV+", id: "350" },
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
      all_movies.concat(parsed_response["results"])
    end

    party_players.each do |party_player|
      selected_movies = all_movies.sample(20)
      party_player.update(movies: selected_movies)
    end

    all_player_movies = party_players.map { |player| player.movies }.flatten.map { |movie| movie["id"] }
    update(movies: all_player_movies)
  end

  def started?
    start
  end

  def movies_assigned?
    movies.present?
  end

  def all_players_finished_swiping?
    party_players.all? do |player|
      player.swipes.count >= player.movies.count
    end
  end

  def assign_final_movies!
    # Return existing final_movies if they are already set and not empty
    return final_movies if final_movies.present?
    return [] unless all_players_finished_swiping?

    # Get all liked swipes and their tags
    tags_liked = swipes.where(is_liked: true).pluck(:tags).flatten
    return [] if tags_liked.empty?

    # Update party tags and get most common ones
    update(tags: tags_liked)
    tags_count = tags_liked.tally
    max_count = tags_count.values.max
    tags_final = tags_count.select { |_key, value| value == max_count }.keys

    all_movies = []

    for i in 1..5
      url = "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=fr-FR&watch_region=FR&page=#{i}"
      url += "&with_watch_providers=#{platform_setting.join('|')}" if platform_setting.present?
      url += "&with_genres=#{tags_final.join('|')}" if tags_final.present?
      url += "&primary_release_date.gte=#{start_year}-01-01" if start_year.present?
      url += "&primary_release_date.lte=#{end_year}-12-31" if end_year.present?
      url += "&api_key=#{ENV['TMDB_API_KEY']}"

      Rails.logger.debug "API URL: #{url}" # Better debugging

      response = URI.open(url).read
      parsed_response = JSON.parse(response)
      all_movies.concat(parsed_response["results"])
    end

    # Filter out movies that were already shown and select 3 random ones
    final_movies = (all_movies.reject { |movie| movies.include?(movie["id"]) }).sample(3)

    if final_movies.present?
      return final_movies  # Return the existing final_movies
    else
      final_movies = (all_movies.reject { |movie| movies.include?(movie["id"]) }).sample(3)
      update(final_movies: final_movies)
      return final_movies
    end
  end

  def all_players_finished_final_swipes?
    party_players.all? do |player|
      player.swipes.where(movie_id: final_movies.map { |m| m['id'] }).count >= final_movies.length
    end
  end
end
