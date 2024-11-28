class Swipe < ApplicationRecord
  belongs_to :party_player
  has_one :party, through: :party_player
  has_one :user, through: :party_player

  def self.most_liked_category
    Swipe.where(is_liked: true).group(:tags).order('count_id DESC').count(:id).first
  end
end
