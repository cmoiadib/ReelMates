class SwipesController < ApplicationController
  def show
    @swipe = Swipe.find(params[:id])
  end

  def new
    @swipe = Swipe.new
  end

  def create
    @swipe = Swipe.new(swipe_params)
    if @swipe.save
      redirect_to @swipe
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def swipe_params
    params.require(:swipe).permit(:guest_id, :party_id)
  end
end
