class SignupController < ApplicationController
  def index
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    
    if @user.save
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to login_url
    else
      flash.now[:error] = "An error occurred during sign up. Please check your information."
      render :index
    end
  end
end
