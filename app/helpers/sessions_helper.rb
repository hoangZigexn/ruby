module SessionsHelper

  # Logs in the given user.
  def log_in(user)
    session[:user_id] = user.id
  end

  # Remembers a user in a persistent session.
  def remember(user)
    user.remember
    cookies.permanent.signed[:user_id] = user.id
    cookies.permanent[:remember_token] = user.remember_token
  end

  # Returns the user corresponding to the remember token cookie.
  def current_user
    return @current_user if defined?(@current_user)
    return nil unless session[:user_id]

    @current_user = User.find_by_id(session[:user_id])
    session.delete(:user_id) unless @current_user
    @current_user
  end

  # Returns true if the user is logged in, false otherwise.
  def logged_in?
    !current_user.nil?
  end

  # Forgets a persistent session.
  def forget(user)
    user.forget
    cookies.delete(:user_id)
    cookies.delete(:remember_token)
  end

  # Logs out the current user.
  def log_out
    forget(current_user)
    session.delete(:user_id)
    @current_user = nil
  end

  # Returns true if the given user is the current user.
  def current_user?(user)
    user == current_user
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end

  # Stores the URL trying to be accessed.
  def store_location
    session[:forwarding_url] = request.url if request.get?
  end

  # Confirms the correct user.
  def correct_user
    @user = User.find(params[:id])
    redirect_to(notfound_path) unless current_user?(@user)
  end

  # Returns the Gravatar for the given user.
  def gravatar_for(user, options = { size: 80 })
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end

  # Returns true if the current user is admin.
  def admin_user?
    current_user && current_user.admin?
  end

  # Confirms an admin user.
  def admin_user
    redirect_to(notfound_path) unless admin_user?
  end

  # Confirms the user has permission to view the profile.
  def authorized_user
    @user = User.find(params[:id])
    unless current_user?(@user) || admin_user?
      flash[:danger] = "You don't have permission to view this profile."
      redirect_to(notfound_path)
    end
  end
end
