class EquipmentPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    return true if user.admin? || user.metrologist?
    return false if user.department_id.blank?
    return false unless record.department_id == user.department_id

    user.customer? ? record.in_service? : true
  end

  def create?
    user.admin? || user.metrologist?
  end

  def update?
    user.admin? || user.metrologist?
  end

  def destroy?
    false
  end

  class Scope < Scope
    def resolve
      if user.admin? || user.metrologist?
        scope.all
      elsif user.department_id.present?
        relation = scope.where(department_id: user.department_id)
        user.customer? ? relation.where(status: :in_service) : relation
      else
        scope.none
      end
    end
  end
end