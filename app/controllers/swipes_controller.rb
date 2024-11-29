require "open-uri"
require "json"


class SwipesController < ApplicationController
  def index
    @party = Party.find(params[:party_id])
    @providers = @party.platform_setting
    @categories = @party.category_setting
    @start_year = @party.start_year
    @end_year = @party.end_year

    all_movies = []

    for i in 1..20
      @url = "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=fr-FR&watch_region=FR&page=#{i}"
      @url += "&with_watch_providers=#{@providers.join('|')}" if @providers.present?
      @url += "&with_genres=#{@categories.join('|')}" if @categories.present?
      @url += "&primary_release_date.gte=#{@start_year}-01-01" if @start_year.present?
      @url += "&primary_release_date.lte=#{@end_year}-12-31" if @end_year.present?
      @url += "&api_key=#{ENV['TMDB_API_KEY']}"

      response = URI.open(@url).read
      parsed_response = JSON.parse(response)
      @all_movies = all_movies.concat(parsed_response["results"])
    end
    @party_player = PartyPlayer.find_by(user: current_or_guest_user, party: @party)

    @player_movies = @all_movies.sample(20)
    @party_player.update(movies: @player_movies)
    @party.update(movies: @player_movies.map { |movie| movie["id"] })
  end

  def result
    @party = Party.find(params[:id])
    @movies_ids = PartyPlayer.find_by(user: current_or_guest_user, party: @party).swipes.pluck(:movie_id)
    @tags_liked = PartyPlayer.find_by(user: current_or_guest_user, party: @party).swipes.where(is_liked: true).pluck(:tags).flatten
    @party.update(tags: @tags_liked, movies: @movies_ids)

    tags_count = @tags_liked.tally
    max_count = tags_count.values.max
    @tags_final = tags_count.select { |_key, value| value == max_count }.keys

    @providers = @party.platform_setting
    @start_year = @party.start_year
    @end_year = @party.end_year

    all_movies = []

    for i in 1..5
      @url = "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=fr-FR&watch_region=FR&page=#{i}"
      @url += "&with_watch_providers=#{@providers.join('|')}" if @providers.present?
      @url += "&with_genres=#{@tags_final.join('|')}" if @tags_final.present?
      @url += "&primary_release_date.gte=#{@start_year}-01-01" if @start_year.present?
      @url += "&primary_release_date.lte=#{@end_year}-12-31" if @end_year.present?
      @url += "&api_key=#{ENV['TMDB_API_KEY']}"

      response = URI.open(@url).read
      parsed_response = JSON.parse(response)
      @all_movies = all_movies.concat(parsed_response["results"])
    end
    @final_movies = (@all_movies.reject { |movie| @movies_ids.include?(movie["id"]) }).sample(3)
    @party.update(final_movies: @final_movies)
  end

  def show
    @swipe = Swipe.find(params[:id])
  end

  def new
    swipe = Swipe.new(swipe_params)
    @party = swipe.party_player.party
    @party_player = PartyPlayer.find_by(user: current_or_guest_user, party: @party)
    if swipe.save
      flash[:notice] = "Swipe enregistré"
      @party_player.swipes.pluck(:movie_id).uniq.each do |movie_id|
        @party_player.movies.delete_if { |movie| movie["id"] == movie_id }
      end
      render :index
    else
      flash[:alert] = "Erreur lors de l'enregistrement du swipe"
    end
  end

  def create
    swipe = Swipe.new(swipe_params)

    if swipe.save
      render json: { message: 'Swipe enregistré' }, status: :ok
    else
      render json: { error: 'Erreur lors de l\'enregistrement du swipe' }, status: :unprocessable_entity
    end
  end

  private

  def swipe_params
    params.require(:swipe).permit(:party_player_id, :movie_id, :is_liked, tags: [])
  end
end
