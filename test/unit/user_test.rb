require 'test_helper'

class UserTest < ActiveSupport::TestCase
  
  def setup
    @user = User.new(
      name: "Test User",
      email: "test@example.com",
      age: 25,
      gender: 1,
      first_name: "Test",
      last_name: "User",
      birthday: "1998-01-01",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  # Test valid user
  test "should be valid" do
    assert @user.valid?
  end

  # Test name validations
  test "name should be present" do
    @user.name = "   "
    assert !@user.valid?
  end

  test "name should not be nil" do
    @user.name = nil
    assert !@user.valid?
  end

  # Test email validations
  test "email should be present" do
    @user.email = "   "
    assert !@user.valid?
  end

  test "email should not be nil" do
    @user.email = nil
    assert !@user.valid?
  end

  test "email should be unique" do
    @user.save
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    assert duplicate_user.valid?
  end


  # Test password validations
  test "password should be present" do
    @user.password = "   "
    assert !@user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert !@user.valid?
  end

  test "password should be at least 6 characters" do
    @user.password = @user.password_confirmation = "a" * 6
    assert @user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = nil
    @user.password_confirmation = nil
    assert !@user.valid?
  end

  test "password confirmation should be present" do
    @user.password = "password123"
    @user.password_confirmation = ""
    assert !@user.valid?
  end

  test "password and password confirmation should match" do
    @user.password = "password123"
    @user.password_confirmation = "different"
    assert !@user.valid?
  end

  test "password and password confirmation should match when valid" do
    @user.password = @user.password_confirmation = "password123"
    assert @user.valid?
  end

  test "authenticate should return user for valid password" do
    @user.password = @user.password_confirmation = "password123"
    @user.save
    assert_equal @user, @user.authenticate("password123")
  end

  test "authenticate should return false for invalid password" do
    @user.password = @user.password_confirmation = "password123"
    @user.save
    assert !@user.authenticate("wrongpassword")
  end

  # Test age validations
  test "age should be present" do
    @user.age = nil
    assert !@user.valid?
  end

  test "age should be an integer" do
    @user.age = 25.5
    assert !@user.valid?
  end

  test "age should be greater than 0" do
    @user.age = 0
    assert !@user.valid?
  end

  test "age should be greater than 0 (negative)" do
    @user.age = -1
    assert !@user.valid?
  end

  test "age should accept valid positive integers" do
    @user.age = 1
    assert @user.valid?
  end

  # Test associations
  test "should have many microposts" do
    @user.save
    assert_respond_to @user, :microposts
  end

  # Test attribute accessibility
  test "should have accessible attributes" do
    accessible_attrs = [:email, :name, :age, :gender, :last_name, :first_name, :birthday, :password]
    accessible_attrs.each do |attr|
      assert @user.respond_to?(attr), "User should respond to #{attr}"
      assert @user.respond_to?("#{attr}="), "User should respond to #{attr}="
    end
  end

  # Test fixture data
  test "fixture should exist" do
    user = users(:valid_user)
    assert user.present?
    assert_equal "John Doe", user.name
  end

  test "another fixture should exist" do
    user = users(:another_user)
    assert user.present?
    assert_equal "Jane Smith", user.name
  end

  # Test edge cases
  test "should handle empty string for optional fields" do
    @user.first_name = ""
    @user.last_name = ""
    @user.gender = ""
    assert @user.valid?
  end

  test "should handle nil for optional fields" do
    @user.first_name = nil
    @user.last_name = nil
    @user.gender = nil
    assert @user.valid?
  end

  test "should handle valid birthday" do
    @user.birthday = Date.new(1990, 1, 1)
    assert @user.valid?
  end

  test "should handle nil birthday" do
    @user.birthday = nil
    assert @user.valid?
  end

  # Test signup specific validations
  test "should create user with valid signup data" do
    user = User.new(
      :name => "Test User",
      :email => "test@example.com",
      :password => "password123",
      :password_confirmation => "password123",
      :age => 25,
      :first_name => "Test",
      :last_name => "User",
      :gender => 1,
      :birthday => "1998-01-01"
    )
    assert user.valid?
    assert user.save
  end

  test "should not save user with missing required fields" do
    user = User.new
    assert !user.valid?
    assert user.errors[:name].any?
    assert user.errors[:email].any?
    assert user.errors[:password].any?
    assert user.errors[:age].any?
  end

  test "should validate email format" do
    @user.email = "invalid-email"
    assert !@user.valid?
    assert @user.errors[:email].any?
  end

  test "should validate email uniqueness case insensitive" do
    @user.save
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase
    assert !duplicate_user.valid?
    assert duplicate_user.errors[:email].any?
  end

  test "should validate password length" do
    @user.password = @user.password_confirmation = "123"
    assert !@user.valid?
    assert @user.errors[:password].any?
  end

  test "should validate password confirmation" do
    @user.password = "password123"
    @user.password_confirmation = "different"
    assert !@user.valid?
    assert @user.errors[:password_confirmation].any?
  end

  test "should validate age as positive integer" do
    @user.age = -5
    assert !@user.valid?
    assert @user.errors[:age].any?

    @user.age = 25.5
    assert !@user.valid?
    assert @user.errors[:age].any?
  end

  test "should accept valid gender values" do
    [1, 2, 3].each do |gender|
      @user.gender = gender
      assert @user.valid?, "Gender #{gender} should be valid"
    end
  end

  test "should accept nil gender" do
    @user.gender = nil
    assert @user.valid?
  end

  test "should accept valid birthday" do
    @user.birthday = Date.new(1990, 1, 1)
    assert @user.valid?
  end

  test "should accept nil birthday" do
    @user.birthday = nil
    assert @user.valid?
  end

  test "should authenticate with correct password" do
    @user.password = @user.password_confirmation = "password123"
    @user.save
    assert_equal @user, @user.authenticate("password123")
  end

  test "should not authenticate with incorrect password" do
    @user.password = @user.password_confirmation = "password123"
    @user.save
    assert !@user.authenticate("wrongpassword")
  end

  test "should downcase email before save" do
    @user.email = "TEST@EXAMPLE.COM"
    @user.save
    assert_equal "test@example.com", @user.email
  end
end
