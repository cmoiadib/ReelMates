class AddMoviesToParties < ActiveRecord::Migration[7.1]
  def change
    add_column :parties, :movies, :string, array: true, default: []
  end
end
