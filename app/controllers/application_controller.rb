class ApplicationController < ActionController::Base
  include Pundit::Authorization

  before_action :set_current_attributes
  before_action :require_login

  helper_method :current_user

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def current_user
    @current_user ||= User.active.includes(:role, :department).find_by(id: session[:user_id])
  end

  def require_login
    return if current_user

    redirect_to login_path, alert: "Для доступа к системе необходимо войти."
  end

  def set_current_attributes
    Current.user = current_user
    Current.request_ip = request.remote_ip
    Current.user_agent = request.user_agent
  end

  def user_not_authorized
    redirect_to root_path, alert: "Недостаточно прав для выполнения этого действия."
  end
end