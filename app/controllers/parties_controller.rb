require "open-uri"
require "json"

class PartiesController < ApplicationController
  def index
  end

  def show
    @party = Party.find(params[:id])
  end

  def new
    @party = Party.new
    fetch_categories
  end

  def create
    @party = Party.new(party_params)
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
    params.require(:party).permit(:platform_setting, :start_year, :end_year, :category_setting)
  end

  def fetch_categories
    api_key = ENV["TMDB_API_KEY"]
    url = "https://api.themoviedb.org/3/genre/movie/list?language=fr&api_key=#{api_key}"
    response = URI.open(url).read
    @categories = JSON.parse(response)["genres"]
  end
end
