class AddAvatarToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :avatar, :string, default: "default_avatar.png"
  end
end
