class SignupController < ApplicationController
  def index
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    
    if @user.save
      flash[:success] = "Đăng ký thành công! Chào mừng bạn đến với cộng đồng của chúng tôi."
      redirect_to root_path
    else
      flash.now[:error] = "Có lỗi xảy ra khi đăng ký. Vui lòng kiểm tra lại thông tin."
      render :index
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :email, :age, :gender, :last_name, :first_name, :birthday, :password, :password_confirmation)
  end
end
