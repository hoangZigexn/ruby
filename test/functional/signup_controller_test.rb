require 'test_helper'

class SignupControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:user)
    assert_template :index
  end

  test "should create user with valid attributes" do
    assert_difference('User.count') do
      post :create, :user => {
        :name => "John Doe",
        :email => "john@example.com",
        :password => "password123",
        :password_confirmation => "password123",
        :age => 25,
        :first_name => "John",
        :last_name => "Doe",
        :gender => 1,
        :birthday => "1998-01-01"
      }
    end

    assert_redirected_to welcome_user_path(assigns(:user))
    assert_equal "Sign up successful! Welcome to our community.", flash[:success]
  end

  test "should not create user with invalid email" do
    assert_no_difference('User.count') do
      post :create, :user => {
        :name => "John Doe",
        :email => "invalid-email",
        :password => "password123",
        :password_confirmation => "password123",
        :age => 25
      }
    end

    assert_template :index
    assert_equal "An error occurred during sign up. Please check your information.", flash[:error]
  end

  test "should not create user with missing name" do
    assert_no_difference('User.count') do
      post :create, :user => {
        :name => "",
        :email => "john@example.com",
        :password => "password123",
        :password_confirmation => "password123",
        :age => 25
      }
    end

    assert_template :index
    assert_equal "An error occurred during sign up. Please check your information.", flash[:error]
  end

  test "should not create user with short password" do
    assert_no_difference('User.count') do
      post :create, :user => {
        :name => "John Doe",
        :email => "john@example.com",
        :password => "123",
        :password_confirmation => "123",
        :age => 25
      }
    end

    assert_template :index
    assert_equal "An error occurred during sign up. Please check your information.", flash[:error]
  end

  test "should not create user with password mismatch" do
    assert_no_difference('User.count') do
      post :create, :user => {
        :name => "John Doe",
        :email => "john@example.com",
        :password => "password123",
        :password_confirmation => "different123",
        :age => 25
      }
    end

    assert_template :index
    assert_equal "An error occurred during sign up. Please check your information.", flash[:error]
  end

  test "should not create user with duplicate email" do
    # Create first user
    User.create!(
      :name => "Existing User",
      :email => "existing@example.com",
      :password => "password123",
      :password_confirmation => "password123",
      :age => 30
    )

    assert_no_difference('User.count') do
      post :create, :user => {
        :name => "John Doe",
        :email => "existing@example.com",
        :password => "password123",
        :password_confirmation => "password123",
        :age => 25
      }
    end

    assert_template :index
    assert_equal "An error occurred during sign up. Please check your information.", flash[:error]
  end

  test "should not create user with invalid age" do
    assert_no_difference('User.count') do
      post :create, :user => {
        :name => "John Doe",
        :email => "john@example.com",
        :password => "password123",
        :password_confirmation => "password123",
        :age => -5
      }
    end

    assert_template :index
    assert_equal "An error occurred during sign up. Please check your information.", flash[:error]
  end

  test "should not create user with missing age" do
    assert_no_difference('User.count') do
      post :create, :user => {
        :name => "John Doe",
        :email => "john@example.com",
        :password => "password123",
        :password_confirmation => "password123"
      }
    end

    assert_template :index
    assert_equal "An error occurred during sign up. Please check your information.", flash[:error]
  end

  test "should create user with all optional fields" do
    assert_difference('User.count') do
      post :create, :user => {
        :name => "Jane Smith",
        :email => "jane@example.com",
        :password => "password123",
        :password_confirmation => "password123",
        :age => 28,
        :first_name => "Jane",
        :last_name => "Smith",
        :gender => 2,
        :birthday => "1995-05-15"
      }
    end

    user = assigns(:user)
    assert_equal "Jane Smith", user.name
    assert_equal "jane@example.com", user.email
    assert_equal 28, user.age
    assert_equal "Jane", user.first_name
    assert_equal "Smith", user.last_name
    assert_equal 2, user.gender
    assert_equal Date.parse("1995-05-15"), user.birthday

    assert_redirected_to welcome_user_path(user)
    assert_equal "Sign up successful! Welcome to our community.", flash[:success]
  end

  test "should handle case insensitive email" do
    assert_difference('User.count') do
      post :create, :user => {
        :name => "John Doe",
        :email => "JOHN@EXAMPLE.COM",
        :password => "password123",
        :password_confirmation => "password123",
        :age => 25
      }
    end

    user = assigns(:user)
    assert_equal "john@example.com", user.email
  end
end
