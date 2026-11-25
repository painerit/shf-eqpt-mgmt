class NotificationsController < ApplicationController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Notification

    scope = policy_scope(Notification).includes(:notifiable).recent
    scope = scope.unread if params[:filter] == "unread"

    @notifications = scope.page(params[:page]).per(20)
    @unread_count = policy_scope(Notification).unread.count
  end

  def update
    notification = Notification.find(params[:id])
    authorize notification

    notification.mark_as_read!

    redirect_to notifications_path(filter: params[:filter]),
                notice: "Уведомление отмечено как прочитанное."
  end

  def read_all
    authorize Notification, :read_all?

    policy_scope(Notification).unread.update_all(read_at: Time.current)

    redirect_to notifications_path, notice: "Все уведомления отмечены как прочитанные."
  end

  def scan
    authorize Notification, :scan?

    result = Notifications::ScanDueSchedules.new.call

    redirect_to notifications_path,
                notice: "Проверка сроков завершена: создано #{result.created}, уже было #{result.skipped}."
  end
end