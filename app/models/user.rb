class User < ActiveRecord::Base
  has_many :microposts
  has_secure_password
  attr_accessible :email, :name, :age, :gender, :last_name, :first_name, :birthday, :password, :password_confirmation, :remember_token
  
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
  
  before_save { self.email = email.downcase }

  # Returns a random token for remember me functionality
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # Remembers a user in the database for use in persistent sessions
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # Returns true if the given token matches the digest
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end

  # Forgets a user (removes remember token)
  def forget
    update_attribute(:remember_digest, nil)
  end

  # Creates a remember token
  attr_accessor :remember_token

  private

    # Returns the hash digest of the given string
    def User.digest(string)
      cost = Rails.env.test? ? BCrypt::Engine::MIN_COST : BCrypt::Engine::DEFAULT_COST
      BCrypt::Password.create(string, cost: cost)
    end
end
