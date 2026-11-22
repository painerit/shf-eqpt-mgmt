class VerificationPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if user.admin? || user.metrologist?
    return false if user.department_id.blank?
    return false unless record.equipment.department_id == user.department_id

    user.customer? ? record.completed? : true
  end

  def create?
    return true if user.admin? || user.metrologist?
    return false unless user.engineer? && user.department_id.present?

    record.equipment.present? && record.equipment.department_id == user.department_id
  end

  def update?
    return false unless record.editable?
    return true if user.admin? || user.metrologist?

    user.engineer? && record.performed_by_id == user.id
  end

  def start?
    update?
  end

  def complete?
    update?
  end

  def cancel?
    return false if record.completed? || record.canceled?

    user.admin? || user.metrologist?
  end

  def protocol?
    show?
  end

  def publish?
    record.completed? && (user.admin? || user.metrologist?)
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.metrologist?
        scope.all
      elsif user.department_id.present?
        relation = scope.joins(:equipment).where(equipment: { department_id: user.department_id })
        user.customer? ? relation.where(status: %w[passed failed]) : relation
      else
        scope.none
      end
    end
  end
end