class MicropostsController < ApplicationController
  before_filter :logged_in_user, only: [:index, :show, :new, :create, :edit, :update, :destroy]
  before_filter :correct_user,   only: [:edit, :update, :destroy]

  def index
    @microposts = Micropost.recent.paginate(page: params[:page], per_page: 10)
  end

  def show
    @micropost = Micropost.find(params[:id])
  end

  def new
    @micropost = current_user.microposts.build
  end

  def edit
    @micropost = current_user.microposts.find(params[:id])
  end

  def create
    @micropost = current_user.microposts.build(micropost_params)
    if @micropost.save
      flash[:success] = "Micropost created!"
      redirect_to current_user
    else
      render 'new'
    end
  end

  def update
    if @micropost.update_attributes(micropost_params)
      flash[:success] = "Micropost updated!"
      redirect_to @micropost
    else
      render 'edit'
    end
  end

  def destroy
    @micropost.destroy
    flash[:success] = "Micropost deleted"
    redirect_to microposts_url || login_url
  end

  private

  def micropost_params
    params[:micropost]
  end

  def correct_user
    @micropost = current_user.microposts.find_by_id(params[:id])
    redirect_to login_url if @micropost.nil?
  end
end
