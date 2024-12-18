class CreatePartyPlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :party_players do |t|
      t.references :party, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
