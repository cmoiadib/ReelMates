class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :party_player, dependent: :destroy
  has_many :swipes, through: :party_players

  validates :username, presence: true, uniqueness: true, length: { minimum: 3, maximum: 12 }
end
