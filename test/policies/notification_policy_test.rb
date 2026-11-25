require "test_helper"

class NotificationPolicyTest < ActiveSupport::TestCase
  test "engineer can read and update own notifications" do
    notification = notifications(:overdue)
    policy = NotificationPolicy.new(users(:engineer), notification)

    assert policy.index?
    assert policy.update?
    assert_not policy.scan?
  end

  test "engineer cannot update another user's notification" do
    policy = NotificationPolicy.new(users(:customer), notifications(:overdue))

    assert_not policy.update?
  end

  test "admin and metrologist can scan due schedules" do
    assert NotificationPolicy.new(users(:admin), Notification).scan?
    assert NotificationPolicy.new(users(:metrologist), Notification).scan?
    assert_not NotificationPolicy.new(users(:customer), Notification).scan?
  end

  test "scope contains only current user notifications" do
    resolved = NotificationPolicy::Scope.new(users(:engineer), Notification.all).resolve

    assert_includes resolved, notifications(:overdue)
    assert_equal users(:engineer).notifications.count, resolved.count
  end
end