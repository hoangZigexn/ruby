require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  def setup
    @user = users(:valid_user)
  end

  test "should get new" do
    get :new
    assert_response :success
    assert_template :new
  end

  test "should login with valid credentials" do
    post :create, :session => {
      :email => @user.email,
      :password => "password123"
    }
    assert_redirected_to @user
    assert_equal @user.id, session[:user_id]
    assert_equal "Welcome back, #{@user.name}!", flash[:success]
  end

  test "should not login with invalid email" do
    post :create, :session => {
      :email => "invalid@example.com",
      :password => "password123"
    }
    assert_template :new
    assert_nil session[:user_id]
    assert_equal "Invalid email/password combination", flash[:error]
  end

  test "should not login with invalid password" do
    post :create, :session => {
      :email => @user.email,
      :password => "wrongpassword"
    }
    assert_template :new
    assert_nil session[:user_id]
    assert_equal "Invalid email/password combination", flash[:error]
  end

  test "should not login with empty credentials" do
    post :create, :session => {
      :email => "",
      :password => ""
    }
    assert_template :new
    assert_nil session[:user_id]
    assert_equal "Invalid email/password combination", flash[:error]
  end

  test "should logout" do
    log_in @user
    assert_equal @user.id, session[:user_id]
    
    delete :destroy
    assert_redirected_to login_url
    assert_nil session[:user_id]
    assert_equal "You have been logged out successfully.", flash[:success]
  end

  test "should logout even when not logged in" do
    delete :destroy
    assert_redirected_to login_url
    assert_equal "You have been logged out successfully.", flash[:success]
  end

  test "should handle case insensitive email" do
    post :create, :session => {
      :email => @user.email.upcase,
      :password => "password123"
    }
    assert_redirected_to @user
    assert_equal @user.id, session[:user_id]
  end

  # Remember me functionality tests
  test "should remember user when remember_me is checked" do
    post :create, :session => {
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

  test "should not remember user when remember_me is not checked" do
    post :create, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "0"
    }
    assert_redirected_to @user
    assert_equal @user.id, session[:user_id]
    assert_nil @user.remember_digest
    assert_nil cookies[:remember_token]
  end

  test "should not remember user when remember_me parameter is missing" do
    post :create, :session => {
      :email => @user.email,
      :password => "password123"
    }
    assert_redirected_to @user
    assert_equal @user.id, session[:user_id]
    assert_nil @user.remember_digest
    assert_nil cookies[:remember_token]
  end

  test "should forget user on logout" do
    # First login with remember me
    post :create, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "1"
    }
    assert_not_nil @user.remember_digest
    assert_not_nil cookies[:remember_token]

    # Then logout
    delete :destroy
    assert_redirected_to login_url
    assert_nil session[:user_id]
    assert_nil cookies[:remember_token]
    assert_nil cookies[:user_id]
  end

  test "should handle remember_me with invalid credentials" do
    post :create, :session => {
      :email => "invalid@example.com",
      :password => "wrongpassword",
      :remember_me => "1"
    }
    assert_template :new
    assert_nil session[:user_id]
    assert_nil cookies[:remember_token]
    assert_equal "Invalid email/password combination", flash[:error]
  end

  test "should update remember_digest when remembering" do
    original_digest = @user.remember_digest
    post :create, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "1"
    }
    @user.reload
    assert_not_equal original_digest, @user.remember_digest
  end

  test "should clear remember_digest when not remembering" do
    # First set a remember digest
    @user.remember
    original_digest = @user.remember_digest
    assert_not_nil original_digest

    # Then login without remember me
    post :create, :session => {
      :email => @user.email,
      :password => "password123",
      :remember_me => "0"
    }
    @user.reload
    assert_nil @user.remember_digest
  end
end
