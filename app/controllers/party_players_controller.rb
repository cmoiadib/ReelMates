class PartyPlayersController < ApplicationController
  def mark_as_done
    @party_player = PartyPlayer.find(params[:id])
    @party_player.update(swiping_completed: true)
    head :ok
  end
end 
