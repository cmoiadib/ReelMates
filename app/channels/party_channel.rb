class PartyChannel < ApplicationCable::Channel
  def subscribed
    party_id = params[:id]
    stream_from "party_#{party_id}"
  end

  def unsubscribed
  end
end
