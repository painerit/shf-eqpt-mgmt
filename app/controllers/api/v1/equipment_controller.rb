module Api
  module V1
    class EquipmentController < BaseController
      before_action :set_equipment, only: [:show, :verifications]

      after_action :verify_authorized, except: :index
      after_action :verify_policy_scoped, only: [:index, :verifications]

      def index
        authorize Equipment

        @equipment = paginate(
          EquipmentQuery.new(scope: policy_scope(Equipment), params: params).call
        )

        render json: {
          data: @equipment.map { |item| EquipmentSerializer.call(item) },
          meta: meta_for(@equipment)
        }
      end

      def show
        authorize @equipment

        recent_verifications = policy_scope(Verification)
                               .where(equipment: @equipment)
                               .includes(:performed_by)
                               .order(Arel.sql("verifications.performed_on DESC NULLS LAST, verifications.created_at DESC"))
                               .limit(10)

        render json: {
          data: EquipmentSerializer.call(@equipment).merge(
            recent_verifications: recent_verifications.map { |item| VerificationSerializer.call(item) }
          )
        }
      end

      def verifications
        authorize @equipment, :show?

        scope = policy_scope(Verification)
                .where(equipment: @equipment)
                .includes(:performed_by)
                .order(Arel.sql("verifications.performed_on DESC NULLS LAST, verifications.created_at DESC"))
        @verifications = paginate(scope)

        render json: {
          data: @verifications.map { |item| VerificationSerializer.call(item) },
          meta: meta_for(@verifications)
        }
      end

      private

      def set_equipment
        @equipment = Equipment.find(params[:id])
      end
    end
  end
end