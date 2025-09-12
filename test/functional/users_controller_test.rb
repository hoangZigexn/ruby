require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  setup do
    @user = users(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, user: { email: @user.email, name: @user.name }
    end

    assert_redirected_to user_path(assigns(:user))
  end

  test "should show user" do
    get :show, id: @user
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @user
    assert_response :success
  end

  test "should update user" do
    put :update, id: @user, user: { email: @user.email, name: @user.name }
    assert_redirected_to user_path(assigns(:user))
  end

  test "should destroy user" do
    assert_difference('User.count', -1) do
      delete :destroy, :id => @user
    end

    assert_redirected_to users_path
  end

  test "should get welcome page" do
    get :welcome, :id => @user
    assert_response :success
    assert_template :welcome
    assert_equal @user, assigns(:user)
  end

  test "should show welcome page with user data" do
    get :welcome, :id => @user
    assert_response :success
    assert_select 'h1', 'Welcome!'
    assert_select 'p', /Your account has been created successfully/
    assert_select 'p', /Full Name: #{@user.name}/
    assert_select 'p', /Email: #{@user.email}/
  end
end
