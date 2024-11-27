require "open-uri"
require "json"

class SwipesController < ApplicationController
  def index
    @party = Party.find(params[:party_id])
    @providers = @party.platform_setting
    @categories = @party.category_setting
    @start_year = @party.start_year
    @end_year = @party.end_year

    @url = "https://api.themoviedb.org/3/discover/movie?include_adult=false&include_video=false&language=fr-FR&watch_region=FR"

    @url += "&with_watch_providers=#{@providers.join('|')}" if @providers.present?
    @url += "&with_genres=#{@categories.join('|')}" if @categories.present?
    @url += "&primary_release_date.gte=#{@start_year}-01-01" if @start_year.present?
    @url += "&primary_release_date.lte=#{@end_year}-12-31" if @end_year.present?
    @url += "&api_key=#{ENV['TMDB_API_KEY']}"

    response = JSON.parse(URI.open(@url).read)
    @movies = response["results"]
  end

  def show
    @swipe = Swipe.find(params[:id])
  end

  def new
    @swipe = Swipe.new
  end

  def create
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
    params.require(:swipe).permit(:guest_id, :party_id, :movie_id, :is_liked, tags: [])
  end
end
