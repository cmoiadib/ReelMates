class SwipesController < ApplicationController
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
