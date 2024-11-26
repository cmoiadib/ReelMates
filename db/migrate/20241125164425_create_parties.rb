class CreateParties < ActiveRecord::Migration[7.1]
  def change
    create_table :parties do |t|
      t.string :party_code
      t.string :platform_setting, array: true, default: []
      t.integer :start_year
      t.integer :end_year
      t.string :category_setting, array: true, default: []
      t.boolean :start
      t.string :tags, array: true, default: []

      t.timestamps
    end
  end
end
