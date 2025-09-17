class Micropost < ActiveRecord::Base
  belongs_to :user
  attr_accessible :content
  
  validates :content, presence: true, length: { maximum: 140 }
  validates :user_id, presence: true
  
  scope :recent, -> { order('created_at DESC') }
  scope :oldest, -> { order('created_at ASC') }
end
