require "test_helper"

class AuditLogTest < ActiveSupport::TestCase
  test "record! stores actor, action and changes" do
    log = AuditLog.record!(
      auditable: equipment(:generator),
      user: users(:admin),
      action: "update",
      audited_changes: { "status" => %w[in_service in_repair] },
      ip_address: "127.0.0.1",
      user_agent: "Minitest"
    )

    assert log.persisted?
    assert_equal users(:admin), log.user
    assert_equal "update", log.action
    assert_equal %w[status], log.changed_fields
  end

  test "user is optional for system actions" do
    log = AuditLog.record!(auditable: equipment(:generator), action: "publish")

    assert log.persisted?
    assert_nil log.user
  end
end