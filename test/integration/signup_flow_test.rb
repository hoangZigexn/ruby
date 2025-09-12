require 'test_helper'

class SignupFlowTest < ActionDispatch::IntegrationTest
  test "complete signup flow with valid data" do
    # Visit signup page
    get signup_path
    assert_response :success
    assert_template 'signup/index'
    assert_select 'h1', 'Sign Up'
    assert_select 'form[action=?]', signup_path
    assert_select 'input[name=?]', 'user[name]'
    assert_select 'input[name=?]', 'user[email]'
    assert_select 'input[name=?]', 'user[password]'
    assert_select 'input[name=?]', 'user[password_confirmation]'
    assert_select 'input[name=?]', 'user[age]'

    # Submit valid signup form
    assert_difference('User.count', 1) do
      post signup_path, :user => {
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

    # Should redirect to welcome page
    assert_redirected_to welcome_user_path(User.last)
    follow_redirect!
    assert_response :success
    assert_template 'users/welcome'
    assert_select 'h1', 'Welcome!'
    assert_select 'p', /Your account has been created successfully/
    
    # Check user data is displayed
    assert_select 'p', /Full Name: John Doe/
    assert_select 'p', /Email: john@example.com/
    assert_select 'p', /Age: 25/
    assert_select 'p', /Gender: Male/
  end

  test "signup flow with validation errors" do
    # Submit invalid signup form
    assert_no_difference('User.count') do
      post signup_path, :user => {
        :name => "",
        :email => "invalid-email",
        :password => "123",
        :password_confirmation => "different",
        :age => -5
      }
    end

    # Should render signup page again with errors
    assert_template 'signup/index'
    assert_select '.alert-danger'
    assert_select 'h4', /error.*occurred/
    assert_select 'li', /can't be blank/
    assert_select 'li', /is invalid/
    assert_select 'li', /is too short/
  end

  test "signup flow with duplicate email" do
    # Create existing user
    existing_user = User.create!(
      :name => "Existing User",
      :email => "existing@example.com",
      :password => "password123",
      :password_confirmation => "password123",
      :age => 30
    )

    # Try to signup with same email
    assert_no_difference('User.count') do
      post signup_path, :user => {
        :name => "New User",
        :email => "existing@example.com",
        :password => "password123",
        :password_confirmation => "password123",
        :age => 25
      }
    end

    # Should render signup page with error
    assert_template 'signup/index'
    assert_select '.alert-danger'
    assert_select 'li', /has already been taken/
  end

  test "signup form accessibility and validation" do
    get signup_path
    
    # Check required fields are marked
    assert_select 'input[name=?][required]', 'user[name]', false # We removed required from HTML
    assert_select 'input[name=?][required]', 'user[email]', false
    assert_select 'input[name=?][required]', 'user[password]', false
    assert_select 'input[name=?][required]', 'user[age]', false
    
    # Check input types
    assert_select 'input[type=?]', 'email'
    assert_select 'input[type=?]', 'password'
    assert_select 'input[type=?]', 'number'
    assert_select 'input[type=?]', 'date'
    assert_select 'select[name=?]', 'user[gender]'
    
    # Check form structure
    assert_select 'form[method=?]', 'post'
    assert_select 'form[action=?]', signup_path
  end

  test "welcome page displays correct user information" do
    # Create a user
    user = User.create!(
      :name => "Jane Smith",
      :email => "jane@example.com",
      :password => "password123",
      :password_confirmation => "password123",
      :age => 28,
      :first_name => "Jane",
      :last_name => "Smith",
      :gender => 2,
      :birthday => "1995-05-15"
    )

    # Visit welcome page
    get welcome_user_path(user)
    assert_response :success
    assert_template 'users/welcome'
    
    # Check user information is displayed correctly
    assert_select 'h1', 'Welcome!'
    assert_select 'p', /Full Name: Jane Smith/
    assert_select 'p', /Email: jane@example.com/
    assert_select 'p', /Age: 28/
    assert_select 'p', /Gender: Female/
    
    # Check navigation links
    assert_select 'a[href=?]', user_path(user), 'View Profile'
    assert_select 'a[href=?]', home_path, 'Go to Home'
  end

  test "signup with minimal required fields" do
    assert_difference('User.count', 1) do
      post signup_path, :user => {
        :name => "Minimal User",
        :email => "minimal@example.com",
        :password => "password123",
        :password_confirmation => "password123",
        :age => 30
      }
    end

    user = User.last
    assert_equal "Minimal User", user.name
    assert_equal "minimal@example.com", user.email
    assert_equal 30, user.age
    assert_nil user.first_name
    assert_nil user.last_name
    assert_nil user.gender
    assert_nil user.birthday

    assert_redirected_to welcome_user_path(user)
  end
end
