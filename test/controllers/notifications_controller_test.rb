require "test_helper"

class NotificationsControllerTest < ActionDispatch::IntegrationTest
  test "shows current user notifications" do
    sign_in_as users(:engineer)

    get notifications_path

    assert_response :success
    assert_match notifications(:overdue).message, response.body
  end

  test "marks notification as read" do
    sign_in_as users(:engineer)
    notification = notifications(:overdue)

    patch notification_path(notification)

    assert_redirected_to notifications_path(filter: nil)
    assert notification.reload.read?
  end

  test "cannot mark another user's notification as read" do
    sign_in_as users(:customer)

    patch notification_path(notifications(:overdue))

    assert_redirected_to root_path
    assert_not notifications(:overdue).reload.read?
  end

  test "marks all notifications as read" do
    sign_in_as users(:engineer)

    patch read_all_notifications_path

    assert_redirected_to notifications_path
    assert_equal 0, users(:engineer).notifications.unread.count
  end

  test "engineer cannot scan due schedules" do
    sign_in_as users(:engineer)

    post scan_notifications_path

    assert_redirected_to root_path
  end

  test "admin can scan due schedules" do
    sign_in_as users(:admin)
    before_count = Notification.count

    post scan_notifications_path

    assert_operator Notification.count, :>, before_count
    assert_redirected_to notifications_path
  end
end