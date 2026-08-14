class User < ApplicationRecord
  has_many :events, dependent: :destroy

  validates :clerk_user_id, presence: true, uniqueness: true
end
