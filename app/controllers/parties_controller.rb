class PartiesController < ApplicationController
  def show
    @party = Party.find(params[:id])
  end

  def new
    @party = Party.new
  end

  def create
    @party = Party.new(party_params)
    if @party.save
      redirect_to @party
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def party_params
    params.require(:party).permit(:platform_settings, :period_settings, :category_settings)
  end
end
