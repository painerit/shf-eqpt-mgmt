class RegistrationsController < ApplicationController
  skip_before_action :require_login, only: [:new, :create]

  def new
    redirect_to root_path if current_user

    @user = User.new
    load_departments
  end

  def create
    @user = User.new(registration_params)
    @user.role = Role.find_by!(code: "customer")
    @user.active = true

    if @user.save
      reset_session
      session[:user_id] = @user.id
      redirect_to root_path, notice: "Регистрация завершена. Добро пожаловать!"
    else
      load_departments
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to signup_path, alert: "Роль заказчика не настроена. Обратитесь к администратору."
  end

  private

  def registration_params
    params.require(:user).permit(
      :email,
      :full_name,
      :phone,
      :department_id,
      :password,
      :password_confirmation
    )
  end

  def load_departments
    @departments = Department.active.order(:name)
  end
end