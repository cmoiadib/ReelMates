require "open-uri"
require "json"


class PartiesController < ApplicationController
  before_action :fetch_categories, only: :new

  def index
    if params[:party_code].present?
      party = Party.find_by(party_code: params[:party_code])
      if party
        if !party.start?
          @party_player = PartyPlayer.create(user: current_or_guest_user, party: party)
          redirect_to party_path(party)
        else
          flash.now[:alert] = "Party already started"
          render :index
        end
      else
        flash.now[:alert] = "Invalid code"
        render :index
      end
    end
  end

  def show
    @party = Party.find(params[:id])
    @party_player = @party.party_players.find_by(user: current_or_guest_user)
  end

  def new
    @party = Party.new
  end

  def start
    @party = Party.find(params[:id])
    @party.update(start: true)
    redirect_to party_swipes_path(@party)
  end

  def create
    @party = Party.new(party_params)
    @party.start = false
    @party.admin = current_or_guest_user
    @party.party_code = rand(100000..999999)
    @party_player = PartyPlayer.create(user: current_or_guest_user, party: @party)
    if @party.save
      redirect_to party_path(@party), notice: 'Party was successfully created.'
    else
      render :new
    end
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

  def final_result
    @party = Party.find(params[:id])
    @party_player = PartyPlayer.find_by(user: current_or_guest_user, party: @party)
    @winning_movie = find_winning_movie
  end

  private

  def party_params
    params.require(:party).permit(:start_year, :end_year, category_setting: [], platform_setting: [])
  end

  def fetch_categories
    api_key = ENV["TMDB_API_KEY"]
    url = "https://api.themoviedb.org/3/genre/movie/list?language=fr&api_key=#{api_key}"
    response = URI.open(url).read
    @categories = JSON.parse(response)["genres"]
  end

  def find_winning_movie
    movies_liked = @party_player.swipes.where(is_liked: true).pluck(:movie_id)
    likes_count = movies_liked.tally
    total_players = @party.party_players.count

    unanimous_movies = likes_count.select { |_movie_id, likes| likes == total_players }.keys
    unanimous_movies.first || likes_count.max_by { |_movie_id, likes| likes }.first
  end
end
