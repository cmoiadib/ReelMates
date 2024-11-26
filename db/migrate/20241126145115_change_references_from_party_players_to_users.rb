class ChangeReferencesFromPartyPlayersToUsers < ActiveRecord::Migration[7.1]
  def change
    remove_reference :parties, :party_player, foreign_key: true
    add_reference :parties, :user, null: false, foreign_key: true

  end
end
