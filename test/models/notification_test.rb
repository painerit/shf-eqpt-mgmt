require "test_helper"

class NotificationTest < ActiveSupport::TestCase
  test "same event is not duplicated" do
    duplicate = notifications(:overdue).dup

    assert_not duplicate.valid?
    assert duplicate.errors[:kind].any?
  end

  test "mark_as_read! sets timestamp" do
    notification = notifications(:overdue)

    notification.mark_as_read!

    assert notification.read?
    assert_not_nil notification.read_at
  end
end