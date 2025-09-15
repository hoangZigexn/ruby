class User < ActiveRecord::Base
  has_many :microposts
  has_secure_password
  
  attr_accessible :email, :name, :age, :gender, :last_name, :first_name, :birthday, 
                  :password, :password_confirmation, :admin
  
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, presence: { message: "can't be blank" }, 
            uniqueness: { message: "has already been taken" }, 
            format: { with: VALID_EMAIL_REGEX, message: "is invalid" }
  validates :name, presence: { message: "can't be blank" }
  validates :password, presence: { message: "can't be blank" }, 
            length: { minimum: 6, message: "is too short (minimum is 6 characters)" }
  validates :password_confirmation, presence: { message: "can't be blank" }
  validates :age, presence: { message: "can't be blank" }, 
            numericality: { only_integer: true, greater_than: 0, message: "must be a positive integer" }
  
  before_save :downcase_email

  private

  def downcase_email
    self.email = email.downcase
  end
end
