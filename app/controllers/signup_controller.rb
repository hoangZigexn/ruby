class SignupController < ApplicationController
  def index
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      flash[:success] = "Sign up successful! Welcome to our community."
      redirect_to welcome_user_path(@user)
    else
      flash.now[:error] = "An error occurred during sign up. Please check your information."
      render :index
    end
  end
end
