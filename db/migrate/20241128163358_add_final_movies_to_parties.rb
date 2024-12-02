class AddFinalMoviesToParties < ActiveRecord::Migration[7.1]
  def change
    add_column :parties, :final_movies, :jsonb, default: [], null: false
  end
end
