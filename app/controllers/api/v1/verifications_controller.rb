module Api
  module V1
    class VerificationsController < BaseController
      before_action :set_verification, only: :show

      after_action :verify_authorized
      after_action :verify_policy_scoped, only: :index

      def index
        authorize Verification

        @verifications = paginate(
          VerificationQuery.new(
            scope: policy_scope(Verification),
            params: params
          ).call
        )

        render json: {
          data: @verifications.map { |item| VerificationSerializer.call(item) },
          meta: meta_for(@verifications)
        }
      end

      def show
        authorize @verification

        render json: {
          data: VerificationSerializer.call(@verification, include_results: true)
        }
      end

      private

      def set_verification
        @verification = Verification.find(params[:id])
      end
    end
  end
end