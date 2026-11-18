module Admin
  class UsersController < ApplicationController
    after_action :verify_authorized

    before_action :load_form_collections, only: [:new, :create, :edit, :update]

    def index
      authorize User

      @users = policy_scope(User)
               .includes(:role, :department)
               .order(:full_name)
               .page(params[:page])
               .per(20)
    end

    def new
      @user = User.new(role: Role.find_by(code: "engineer"))
      authorize @user
    end

    def create
      @user = User.new(user_params)
      authorize @user

      if @user.save
        redirect_to admin_users_path, notice: "Пользователь создан."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
      @user = User.find(params[:id])
      authorize @user
    end

    def update
      @user = User.find(params[:id])
      authorize @user

      if @user.update(user_params)
        redirect_to admin_users_path, notice: "Данные пользователя обновлены."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    private

    def user_params
      attributes = [:email, :full_name, :phone, :role_id, :department_id, :active]
      attributes += [:password, :password_confirmation] if params.dig(:user, :password).present?

      params.require(:user).permit(*attributes)
    end

    def load_form_collections
      @roles = Role.order(:name)
      @departments = Department.active.order(:name)
    end
  end
end