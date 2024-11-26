class AddPartyPlayerReferenceToParty < ActiveRecord::Migration[7.1]
  def change
    add_reference :parties, :party_player, foreign_key: true
  end
end
