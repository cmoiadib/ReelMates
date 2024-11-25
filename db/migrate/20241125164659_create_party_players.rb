class CreatePartyPlayers < ActiveRecord::Migration[7.1]
  def change
    create_table :party_players do |t|
      t.references :party_id, null: false, foreign_key: true
      t.references :user_id, null: false, foreign_key: true
      t.boolean :is_user

      t.timestamps
    end
  end
end
