require 'test_helper'

class SessionsHelperTest < ActionView::TestCase
  def setup
    @user = users(:valid_user)
  end

  test "should log in a user" do
    log_in(@user)
    assert_equal @user.id, session[:user_id]
  end

  test "should return current user from session" do
    log_in(@user)
    assert_equal @user, current_user
  end

  test "should return nil for current user when not logged in" do
    assert_nil current_user
  end

  test "should return true for logged_in? when user is logged in" do
    log_in(@user)
    assert logged_in?
  end

  test "should return false for logged_in? when user is not logged in" do
    assert_not logged_in?
  end

  test "should log out a user" do
    log_in(@user)
    assert logged_in?
    log_out
    assert_not logged_in?
    assert_nil session[:user_id]
  end

  test "should return true for current_user? with correct user" do
    log_in(@user)
    assert current_user?(@user)
  end

  test "should return false for current_user? with different user" do
    log_in(@user)
    other_user = users(:another_user)
    assert_not current_user?(other_user)
  end

  test "should return false for current_user? when not logged in" do
    assert_not current_user?(@user)
  end

  test "should store location" do
    request.url = "http://example.com/test"
    store_location
    assert_equal "http://example.com/test", session[:forwarding_url]
  end

  test "should redirect back or default" do
    session[:forwarding_url] = "http://example.com/test"
    redirect_back_or(@user)
    assert_redirected_to "http://example.com/test"
    assert_nil session[:forwarding_url]
  end

  test "should redirect to default when no forwarding url" do
    redirect_back_or(@user)
    assert_redirected_to @user
  end

  # Remember me functionality tests
  test "should remember a user" do
    remember(@user)
    assert_equal @user.id, cookies.signed[:user_id]
    assert_equal @user.remember_token, cookies[:remember_token]
    assert_not_nil @user.remember_digest
  end

  test "should return current user from remember token cookie" do
    remember(@user)
    assert_equal @user, current_user
    assert logged_in?
  end

  test "should return nil for current user with invalid remember token" do
    remember(@user)
    cookies[:remember_token] = "wrong_token"
    assert_nil current_user
    assert_not logged_in?
  end

  test "should return nil for current user with non-existent user id" do
    remember(@user)
    cookies.signed[:user_id] = 99999
    assert_nil current_user
    assert_not logged_in?
  end

  test "should forget a user" do
    remember(@user)
    assert_not_nil cookies[:remember_token]
    forget(@user)
    assert_nil cookies[:remember_token]
    assert_nil cookies[:user_id]
    assert_nil @user.remember_digest
  end

  test "should log out and forget user" do
    remember(@user)
    log_in(@user)
    assert logged_in?
    log_out
    assert_not logged_in?
    assert_nil cookies[:remember_token]
    assert_nil cookies[:user_id]
  end

  test "should prioritize session over remember token" do
    remember(@user)
    other_user = users(:another_user)
    log_in(other_user)
    assert_equal other_user, current_user
  end

  test "should clear remember token when user is deleted" do
    remember(@user)
    @user.destroy
    assert_nil current_user
  end

  test "should handle nil remember token gracefully" do
    remember(@user)
    cookies[:remember_token] = nil
    assert_nil current_user
  end

  test "should handle empty remember token gracefully" do
    remember(@user)
    cookies[:remember_token] = ""
    assert_nil current_user
  end
end
