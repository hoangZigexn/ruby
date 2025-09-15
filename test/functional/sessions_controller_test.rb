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
end
