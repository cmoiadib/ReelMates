class SwipesController < ApplicationController
  def index
    @party = Party.find(params[:party_id])
    @party_player = PartyPlayer.find_by(user: current_or_guest_user, party: @party)
  end

  def show
    @swipe = Swipe.find(params[:id])
  end

  def new
    swipe = Swipe.new(swipe_params)
    @party = swipe.party_player.party
    @party_player = PartyPlayer.find_by(user: current_or_guest_user, party: @party)
    if swipe.save
      flash[:notice] = "Swipe enregistré"
      @party_player.swipes.pluck(:movie_id).uniq.each do |movie_id|
        @party_player.movies.delete_if { |movie| movie["id"] == movie_id }
      end
      render :index
    else
      flash[:alert] = "Erreur lors de l'enregistrement du swipe"
    end
  end

  def create
    swipe = Swipe.new(swipe_params)

    if swipe.save
      render json: { message: 'Swipe enregistré', last_swipe: last_swipe?(swipe) }, status: :ok
    else
      render json: { error: 'Erreur lors de l\'enregistrement du swipe' }, status: :unprocessable_entity
    end
  end

  private

  def swipe_params
    params.require(:swipe).permit(:party_player_id, :movie_id, :is_liked, tags: [])
  end

  def last_swipe?(swipe)
    swipe.party_player.movies.last["id"] == swipe.movie_id
  end
end
