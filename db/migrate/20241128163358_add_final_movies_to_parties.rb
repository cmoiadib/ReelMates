class AddFinalMoviesToParties < ActiveRecord::Migration[7.1]
  def change
    add_column :parties, :final_movies, :jsonb, array: true, default: []
  end
end
