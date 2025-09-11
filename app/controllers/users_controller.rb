class UsersController < ApplicationController
  before_filter :logged_in_user, only: [:index, :show, :edit, :update, :destroy]
  before_filter :authorized_user, only: [:show]
  before_filter :correct_user, only: [:edit, :update]
  before_filter :admin_user, only: :destroy
  
  # GET /users
  # GET /users.json
  def index
    @users = User.paginate(page: params[:page], per_page: 10)

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @users }
    end
  end

  # GET /users/1
  # GET /users/1.json
  def show
    @user = User.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/new
  # GET /users/new.json
  def new
    @user = User.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @user }
    end
  end

  # GET /users/1/edit
  def edit
    @user = User.find(params[:id])
  end

  # GET /users/1/welcome
  def welcome
    @user = User.find(params[:id])
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(params[:user])

    respond_to do |format|
      if @user.save
        log_in @user
        format.html { redirect_to @user, notice: 'Welcome to the Sample App!' }
        format.json { render json: @user, status: :created, location: @user }
      else
        format.html { render action: "new" }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /users/1
  # PUT /users/1.json
  def update
    respond_to do |format|
      # Handle password update logic
      password = params[:user][:password]
      password_confirmation = params[:user][:password_confirmation]
      
      # Only change password if both fields are present
      if password.present? && password_confirmation.present?
        # User wants to change password - both fields are filled
        if @user.update_attributes(params[:user])
          format.html { redirect_to @user, notice: 'Profile updated successfully' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      else
        # User doesn't want to change password - remove password fields
        params[:user].delete(:password)
        params[:user].delete(:password_confirmation)
        
        if @user.update_attributes(params[:user])
          format.html { redirect_to @user, notice: 'Profile updated successfully' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @user.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

end
