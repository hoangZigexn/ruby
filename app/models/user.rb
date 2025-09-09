class User < ActiveRecord::Base
  has_many :microposts
  has_secure_password
  attr_accessible :email, :name, :age, :gender, :last_name, :first_name, :birthday, :password, :password_confirmation
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: true, uniqueness: true, format: { with: VALID_EMAIL_REGEX }
  validates :name, presence: true
  validates :password, length: { minimum: 6 }
  validates :age, numericality: { only_integer: true, greater_than: 0 }
  
  before_save { self.email = email.downcase }
end
