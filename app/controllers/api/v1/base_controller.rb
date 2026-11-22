module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_request!

      rescue_from Pundit::NotAuthorizedError, with: :render_forbidden
      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActiveRecord::RecordInvalid, with: :render_unprocessable
      rescue_from ActionController::ParameterMissing, with: :render_unprocessable

      def current_user
        @current_user
      end

      private

      def authenticate_request!
        payload = JsonWebToken.decode(bearer_token)
        @current_user = User.active.includes(:role, :department).find_by(id: payload&.[](:user_id))

        if @current_user
          set_current_attributes
          return
        end

        render_error(:unauthorized, "Требуется авторизация", :unauthorized)
      end

      def bearer_token
        scheme, token = request.headers["Authorization"].to_s.split(" ", 2)
        return unless scheme&.casecmp("Bearer")&.zero?

        token
      end

      def set_current_attributes
        Current.user = @current_user
        Current.request_ip = request.remote_ip
        Current.user_agent = request.user_agent
      end

      def paginate(scope)
        page = params[:page].to_i
        page = 1 unless page.positive?

        per_page = params[:per_page].to_i
        per_page = 20 unless per_page.positive?
        per_page = [per_page, 100].min

        scope.page(page).per(per_page)
      end

      def meta_for(collection)
        {
          page: collection.current_page,
          per_page: collection.limit_value,
          total: collection.total_count,
          total_pages: collection.total_pages
        }
      end

      def render_error(code, message, status)
        render json: { error: { code: code.to_s, message: message } }, status: status
      end

      def render_forbidden
        render_error(:forbidden, "Недостаточно прав для выполнения этого действия", :forbidden)
      end

      def render_not_found
        render_error(:not_found, "Ресурс не найден", :not_found)
      end

      def render_unprocessable(exception)
        message = exception.respond_to?(:record) ? exception.record.errors.full_messages.to_sentence : exception.message
        render_error(:unprocessable_entity, message.presence || "Некорректные параметры запроса", :unprocessable_entity)
      end
    end
  end
end