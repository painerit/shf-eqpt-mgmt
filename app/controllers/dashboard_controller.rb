class DashboardController < ApplicationController
  after_action :verify_authorized

  def index
    authorize :dashboard, :show?

    equipment_scope = scoped_equipment
    equipment_ids = equipment_scope.select(:id)

    @equipment_total = equipment_scope.count
    @overdue_equipment = equipment_scope
                         .overdue
                         .includes(:equipment_type, :department, :responsible_user)
                         .order(:next_verification_on)
                         .limit(8)
    @due_soon_equipment = equipment_scope
                          .due_soon
                          .includes(:equipment_type, :department, :responsible_user)
                          .order(:next_verification_on)
                          .limit(8)
    @upcoming_schedules = VerificationSchedule
                          .where(equipment_id: equipment_ids)
                          .upcoming
                          .where(status: [:planned, :approved])
                          .includes(:equipment, :responsible_user)
                          .order(:planned_on)
                          .limit(8)
    @recent_verifications = Verification
                            .where(equipment_id: equipment_ids)
                            .completed
                            .includes(:equipment, :performed_by)
                            .order(performed_on: :desc, created_at: :desc)
                            .limit(8)
    @notifications = current_user.notifications.unread.recent.limit(6)
    @unread_notifications_count = current_user.notifications.unread.count

    @stats = {
      overdue: equipment_scope.overdue.count,
      due_soon: equipment_scope.due_soon.count,
      verifications_this_month: Verification.where(equipment_id: equipment_ids).this_month.count,
      passed: Verification.where(equipment_id: equipment_ids, status: :passed).count,
      failed: Verification.where(equipment_id: equipment_ids, status: :failed).count,
      departments: Department.active.count
    }
  end

  private

  def scoped_equipment
    scope =
      if current_user.admin? || current_user.metrologist?
        Equipment.all
      elsif current_user.department_id.present?
        Equipment.where(department_id: current_user.department_id)
      else
        Equipment.none
      end

    current_user.customer? ? scope.where(status: :in_service) : scope
  end
end