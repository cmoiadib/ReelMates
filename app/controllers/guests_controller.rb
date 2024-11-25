class GuestsController < ApplicationController
  def new
    @guest = Guest.new
  end

  def create
    @guest = Guest.new(guest_params)
    if @guest.save
      redirect_to party_path(@party)
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def guest_params
    params.require(:guest).permit(:username)
  end
end
