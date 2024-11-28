class AddMoviesToPartyPlayer < ActiveRecord::Migration[7.1]
  def change
    add_column :party_players, :movies, :jsonb, array: true, default: []
  end
end
