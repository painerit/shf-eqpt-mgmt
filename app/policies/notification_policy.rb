class NotificationPolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def update?
    record.user_id == user.id
  end

  def read_all?
    user.present?
  end

  def scan?
    user.admin? || user.metrologist?
  end

  class Scope < Scope
    def resolve
      scope.where(user_id: user.id)
    end
  end
end