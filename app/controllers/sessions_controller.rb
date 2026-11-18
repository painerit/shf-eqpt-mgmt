class SessionsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if current_user
  end

  def create
    user = User.authenticate(params[:email], params[:password])

    if user
      reset_session
      session[:user_id] = user.id
      Current.user = user
      redirect_to root_path, notice: "Вы успешно вошли в систему."
    else
      @email = params[:email]
      flash.now[:alert] = "Неверный email или пароль."
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "Вы вышли из системы."
  end
end