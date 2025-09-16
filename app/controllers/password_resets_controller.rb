class PasswordResetsController < ApplicationController
  before_filter :get_user,   only: [:edit, :update]
  before_filter :valid_user, only: [:edit, :update]
  before_filter :check_expiration, only: [:edit, :update]

  def new
  end

  def create
    puts "params: #{params}"
    @user = User.find_by_email(params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to login_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?
      @user.errors.add(:password, "can't be empty")
      render 'edit'
    elsif @user.update_attributes(user_params)
      @user.update_attribute(:reset_digest, nil)
      log_in @user
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'
    end
  end

  private

  def user_params
    params[:user]
  end

  def get_user
    @user = User.find_by_email(params[:email].downcase)
    @user.reset_token = params[:id] if @user
  end

  # Confirms a valid user.
  def valid_user
    return if @user&.activated? && @user.authenticated?(:reset, params[:id])
    redirect_to login_url
  end

  # Checks expiration of reset token.
  def check_expiration
    return unless @user.password_reset_expired?
  
    flash[:danger] = "Password reset has expired."
    redirect_to new_password_reset_url
  end
end
