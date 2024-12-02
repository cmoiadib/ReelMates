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

    ActionCable.server.broadcast(
      "party_#{@party.id}",
      {
        action: 'game_started',
        redirect_url: party_swipes_path(@party)
      }
    )

    head :ok
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

    # Initialize as empty array if nil
    @party.final_movies ||= []

    if @party.final_movies.empty?
      assigned_movies = @party.assign_final_movies!
      @party.update!(final_movies: assigned_movies || [])
    end

    @final_movies = @party.final_movies
  end

  def final_result
    @party = Party.find(params[:id])
    @party_player = PartyPlayer.find_by(user: current_or_guest_user, party: @party)
    @winning_movie = find_winning_movie
  end

  def check_completion
    @party = Party.find(params[:id])
    all_completed = @party.party_players.all?(&:done?)

    render json: { all_completed: all_completed }
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
