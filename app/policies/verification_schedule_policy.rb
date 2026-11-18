class VerificationSchedulePolicy < ApplicationPolicy
  def index?
    !user.customer?
  end

  def show?
    return true if user.admin? || user.metrologist?
    return false if user.customer? || user.department_id.blank?

    record.equipment.department_id == user.department_id
  end

  def create?
    user.admin? || user.metrologist?
  end

  def update?
    user.admin? || user.metrologist?
  end

  def approve?
    user.admin? || user.metrologist?
  end

  def generate?
    user.admin? || user.metrologist?
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.metrologist?
        scope.all
      elsif user.engineer? && user.department_id.present?
        scope.joins(:equipment).where(equipment: { department_id: user.department_id })
      else
        scope.none
      end
    end
  end
end