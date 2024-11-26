class CreateSwipes < ActiveRecord::Migration[7.1]
  def change
    create_table :swipes do |t|
      t.integer :movie_id
      t.boolean :is_liked
      t.string :tags, array: true, default: []
      t.references :party_player, null: false, foreign_key: true

      t.timestamps
    end
  end
end
