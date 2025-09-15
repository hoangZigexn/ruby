require 'test_helper'

class LoginFlowTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:valid_user)
  end

  test "complete login flow with valid credentials" do
    # Visit login page
    get login_path
    assert_response :success
    assert_template 'sessions/new'
    assert_select 'h1', 'Login'
    assert_select 'form[action=?]', login_path
    assert_select 'input[name=?]', 'session[email]'
    assert_select 'input[name=?]', 'session[password]'

    # Submit valid login form
    post login_path, :session => {
      :email => @user.email,
      :password => "password123"
    }

    # Should redirect to user profile
    assert_redirected_to @user
    follow_redirect!
    assert_response :success
    assert_template 'users/show'
    
    # Check session is set
    assert_equal @user.id, session[:user_id]
    
    # Check header shows user dropdown
    assert_select '.dropdown-toggle', @user.name
    assert_select 'a[href=?]', logout_path
  end

  test "login flow with invalid credentials" do
    # Submit invalid login form
    post login_path, :session => {
      :email => @user.email,
      :password => "wrongpassword"
    }

    # Should render login page again with error
    assert_template 'sessions/new'
    assert_select '.alert-danger'
    assert_select 'p', /Invalid email\/password combination/
    assert_nil session[:user_id]
  end

  test "logout flow" do
    # Login first
    log_in @user
    assert_equal @user.id, session[:user_id]

    # Logout
    delete logout_path
    assert_redirected_to login_url
    follow_redirect!
    assert_response :success
    
    # Check session is cleared
    assert_nil session[:user_id]
    
    # Check header shows login/signup links
    assert_select 'a[href=?]', login_path
    assert_select 'a[href=?]', signup_path
  end

  test "login form accessibility" do
    get login_path
    
    # Check form structure
    assert_select 'form[method=?]', 'post'
    assert_select 'form[action=?]', login_path
    
    # Check input types
    assert_select 'input[type=?]', 'email'
    assert_select 'input[type=?]', 'password'
    assert_select 'input[type=?]', 'submit'
    
    # Check labels
    assert_select 'label[for=?]', 'session_email'
    assert_select 'label[for=?]', 'session_password'
  end

  test "redirect after login" do
    # Try to access protected page without login
    get user_path(@user)
    assert_redirected_to login_path
    
    # Login
    post login_path, :session => {
      :email => @user.email,
      :password => "password123"
    }
    
    # Should redirect to originally requested page
    assert_redirected_to @user
  end

  test "login with case insensitive email" do
    post login_path, :session => {
      :email => @user.email.upcase,
      :password => "password123"
    }
    
    assert_redirected_to @user
    assert_equal @user.id, session[:user_id]
  end

  # Remember me functionality tests
  test "login with remember me checked" do
    post login_path, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "1"
    }
    
    assert_redirected_to @user
    assert_equal @user.id, session[:user_id]
    assert_not_nil @user.remember_digest
    assert_equal @user.id, cookies.signed[:user_id]
    assert_equal @user.remember_token, cookies[:remember_token]
  end

  test "login with remember me unchecked" do
    post login_path, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "0"
    }
    
    assert_redirected_to @user
    assert_equal @user.id, session[:user_id]
    assert_nil @user.remember_digest
    assert_nil cookies[:remember_token]
  end

  test "persistent login with remember me" do
    # Login with remember me
    post login_path, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "1"
    }
    
    assert_redirected_to @user
    assert_equal @user.id, session[:user_id]
    assert_not_nil cookies[:remember_token]
    
    # Simulate browser restart (clear session but keep cookies)
    session.clear
    assert_nil session[:user_id]
    
    # Visit a protected page
    get user_path(@user)
    
    # Should be automatically logged in via remember token
    assert_equal @user.id, session[:user_id]
    assert_response :success
    assert_template 'users/show'
  end

  test "logout clears remember me cookies" do
    # Login with remember me
    post login_path, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "1"
    }
    
    assert_not_nil cookies[:remember_token]
    assert_not_nil @user.remember_digest
    
    # Logout
    delete logout_path
    assert_redirected_to login_url
    assert_nil session[:user_id]
    assert_nil cookies[:remember_token]
    assert_nil cookies[:user_id]
    
    # Check that remember_digest is cleared
    @user.reload
    assert_nil @user.remember_digest
  end

  test "remember me checkbox is present in login form" do
    get login_path
    
    assert_select 'input[name=?]', 'session[remember_me]'
    assert_select 'input[type=?]', 'checkbox'
    assert_select 'label[for=?]', 'session_remember_me'
  end

  test "remember me works with invalid credentials" do
    post login_path, :session => {
      :email => @user.email,
      :password => "wrongpassword",
      :remember_me => "1"
    }
    
    assert_template 'sessions/new'
    assert_nil session[:user_id]
    assert_nil cookies[:remember_token]
    assert_select '.alert-danger'
  end

  test "remember me persists across multiple requests" do
    # Login with remember me
    post login_path, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "1"
    }
    
    remember_token = cookies[:remember_token]
    assert_not_nil remember_token
    
    # Clear session
    session.clear
    
    # Make multiple requests
    get user_path(@user)
    assert_equal @user.id, session[:user_id]
    
    get users_path
    assert_equal @user.id, session[:user_id]
    
    get home_path
    assert_equal @user.id, session[:user_id]
  end

  test "remember me token is unique per user" do
    other_user = users(:another_user)
    
    # Login first user with remember me
    post login_path, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "1"
    }
    
    first_token = cookies[:remember_token]
    assert_not_nil first_token
    
    # Logout
    delete logout_path
    
    # Login second user with remember me
    post login_path, :session => {
      :email => other_user.email,
      :password => "password123",
      :remember_me => "1"
    }
    
    second_token = cookies[:remember_token]
    assert_not_nil second_token
    assert_not_equal first_token, second_token
  end
end
