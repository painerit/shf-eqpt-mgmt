module Api
  module V1
    class AuthController < BaseController
      skip_before_action :authenticate_request!, only: :create

      def create
        user = User.authenticate(params[:email], params[:password])

        unless user
          return render_error(:unauthorized, "Неверный email или пароль", :unauthorized)
        end

        render json: {
          token: JsonWebToken.encode({ user_id: user.id }),
          token_type: "Bearer",
          expires_at: JsonWebToken.expires_at.iso8601,
          user: {
            id: user.id,
            email: user.email,
            full_name: user.full_name,
            role: user.role&.name,
            department: user.department&.name
          }
        }
      end
    end
  end
end