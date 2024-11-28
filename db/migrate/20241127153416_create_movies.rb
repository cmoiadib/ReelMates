class CreateMovies < ActiveRecord::Migration[7.1]
  def change
    create_table :movies do |t|
      t.string :title
      t.text :overview
      t.string :poster_url
      t.float :rating
      t.integer :genres
      t.integer :mvdb_id
      t.references :party, null: false, foreign_key: true
      t.timestamps
    end
  end
end
