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
          Turbo::StreamsChannel.broadcast_update_to(
            "party_#{party.id}",
            target: "players_list",
            partial: "parties/players_list",
            locals: { party: party }
          )
          Turbo::StreamsChannel.broadcast_update_to(
            "party_#{party.id}",
            target: "players_count",
            partial: "parties/players_count",
            locals: { party: party }
          )
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
    if @party.update(start: true)
      ActionCable.server.broadcast(
        "party_#{@party.id}",
        {
          action: "game_started",
          redirect_url: party_swipes_path(@party)
        }
      )
      redirect_to party_swipes_path(@party)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def create
    @party = Party.new(party_params)
    @party.start = false
    @party.admin = current_or_guest_user
    @party.party_code = rand(100000..999999)

    current_or_guest_user.update(
      username: params[:username],
      avatar: params[:avatar]
    )

    if @party.save
      PartyPlayer.create(user: current_or_guest_user, party: @party)
      redirect_to party_path(@party), notice: 'Party was successfully created.'
    else
      redirect_to new_party_path
      flash[:alert] = "You must select at least one platform provider to start the party."
    end
  end

  def result
    @party = Party.find(params[:id])
    @party_player = @party.party_players.find_by(user: current_or_guest_user)

    if @party.final_movies.empty? && @party.all_players_finished_swiping?
      assigned_movies = @party.assign_final_movies!
      @party.update!(final_movies: assigned_movies)
    end

    @final_movies = @party.final_movies
  end

  def final_result
    @party = Party.find(params[:id])
    @party_player = PartyPlayer.find_by(user: current_or_guest_user, party: @party)

    # Get all liked swipes for the final movies
    @movies_liked = @party.swipes
      .where(is_liked: true)
      .where(movie_id: @party.final_movies.map { |m| m['id'] })
      .group(:movie_id)
      .count

    total_players = @party.party_players.count

    # Determine the winning movie
    unanimous_movies = @movies_liked.select { |_movie_id, likes| likes == total_players }.keys
    @winning_movie =
      if unanimous_movies.any?
        unanimous_movies.first
      else
        @movies_liked.max_by { |_movie_id, count| count }&.first
      end

    # Make API call to get movie videos if we have a winning movie
    if @winning_movie
      api_key = ENV["TMDB_API_KEY"]
      url = "https://api.themoviedb.org/3/movie/#{@winning_movie}/videos?language=en-US&api_key=#{api_key}"
      response = URI.open(url).read
      videos_data = JSON.parse(response)

      # Find the first trailer or fallback to first video
      @video = videos_data["results"].find { |v| v["type"] == "Trailer" } || videos_data["results"].first
    end
  end

  def check_completion
    @party = Party.find(params[:id])
    all_completed = @party.party_players.all?(&:done?)

    if all_completed
      ActionCable.server.broadcast(
        "party_#{@party.id}",
        {
          action: 'all_completed'
        }
      )
    end

    render json: { all_completed: all_completed }
  end

  private

  def party_params
    params.require(:party).permit(:start_year, :end_year, category_setting: [], platform_setting: [])
  end

  def fetch_categories
    api_key = ENV["TMDB_API_KEY"]
    url = "https://api.themoviedb.org/3/genre/movie/list?language=en-US&api_key=#{api_key}"
    response = URI.open(url).read
    @categories = JSON.parse(response)["genres"]
  end

  def find_winning_movie

  end
end
