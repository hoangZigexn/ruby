class ApplicationController < ActionController::Base
  protect_from_forgery
  include SessionsHelper

  private

  # Confirms a logged-in user.
  def logged_in_user
    return if logged_in?
    store_location
    flash[:error] = "Please log in."
    redirect_to login_url
  end

end
