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
end
