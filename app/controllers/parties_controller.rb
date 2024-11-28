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
end
