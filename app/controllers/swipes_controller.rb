require "open-uri"
require "json"

class SwipesController < ApplicationController
  def index
    @party = Party.find(params[:party_id])
    @providers = @party.platform_setting
    @categories = @party.category_setting
    @start_year = @party.start_year
    @end_year = @party.end_year

    # all_movies = []

    for i in 1..5
      @url = "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=fr-FR&watch_region=FR&page=#{i}"
      @url += "&with_watch_providers=#{@providers.join('|')}" if @providers.present?
      @url += "&with_genres=#{@categories.join('|')}" if @categories.present?
      @url += "&primary_release_date.gte=#{@start_year}-01-01" if @start_year.present?
      @url += "&primary_release_date.lte=#{@end_year}-12-31" if @end_year.present?
      @url += "&api_key=#{ENV['TMDB_API_KEY']}"

      response = URI.open(@url).read
      parsed_response = JSON.parse(response)
      all_movies = parsed_response["results"]
    end
    @party_player = PartyPlayer.find_by(user: current_or_guest_user, party: @party)

    @party_player.update(movies: all_movies)
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
    debugger
    swipe = Swipe.new(swipe_params)
    swipe.party_player_id = current_party_player.id

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
