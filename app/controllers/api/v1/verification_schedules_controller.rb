module Api
  module V1
    class VerificationSchedulesController < BaseController
      after_action :verify_authorized
      after_action :verify_policy_scoped

      def index
        authorize VerificationSchedule

        @schedules = paginate(
          VerificationScheduleQuery.new(
            scope: policy_scope(VerificationSchedule),
            params: params
          ).call
        )

        render json: {
          data: @schedules.map { |item| VerificationScheduleSerializer.call(item) },
          meta: meta_for(@schedules)
        }
      end
    end
  end
end