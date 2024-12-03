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
      party = swipe.party_player.party
      party_player = swipe.party_player
      last_swipe = last_swipe?(swipe)
      all_finished = party.all_players_finished_swiping?

      if all_finished
        assigned_movies = party.assign_final_movies!
        party.update!(final_movies: assigned_movies || [])

        ActionCable.server.broadcast(
          "party_#{party.id}",
          {
            action: 'all_completed',
            redirect_url: result_party_path(party)
          }
        )
      end

      render json: {
        message: 'Swipe enregistré',
        last_swipe: last_swipe,
        all_finished: all_finished,
        redirect_url: result_party_path(party)
      }, status: :ok
    else
      render json: { error: 'Erreur lors de l\'enregistrement du swipe' }, status: :unprocessable_entity
    end
  end

  def undo
    @party = Party.find(params[:party_id])
    @party_player = PartyPlayer.find_by(party: @party, user: current_or_guest_user)

    last_swipe = @party_player.swipes.last

    if last_swipe&.destroy
      render json: { success: true }
    else
      render json: { success: false }, status: :unprocessable_entity
    end
  end

  def final
    swipe = Swipe.new(swipe_params)

    if swipe.save
      party = swipe.party_player.party
      all_completed = party.all_players_finished_final_swipes?

      if all_completed
        ActionCable.server.broadcast(
          "party_#{party.id}",
          {
            action: 'final_completed',
            redirect_url: final_result_party_path(party)
          }
        )
      end

      render json: {
        message: 'Final swipe recorded',
        all_completed: all_completed
      }, status: :ok
    else
      render json: { error: 'Error recording final swipe' }, status: :unprocessable_entity
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
