require "test_helper"

class AuditLogQueryTest < ActiveSupport::TestCase
  setup do
    @update_log = AuditLog.record!(
      auditable: equipment(:generator),
      user: users(:engineer),
      action: "update",
      audited_changes: { "location" => %w[old new] }
    )
  end

  test "filters by event" do
    result = query(event: "update")

    assert_includes result, @update_log
    assert_not_includes result, audit_logs(:created)
  end

  test "filters by user" do
    result = query(user_id: users(:engineer).id)

    assert_includes result, @update_log
    assert_not_includes result, audit_logs(:created)
  end

  test "filters by auditable type" do
    result = query(auditable_type: "Equipment")

    assert_includes result, @update_log
    assert_includes result, audit_logs(:created)
  end

  test "filters by date range" do
    result = query(date_from: Date.current.to_s, date_to: Date.current.to_s)

    assert_includes result, @update_log
  end

  private

  def query(params = {})
    AuditLogQuery.new(
      scope: AuditLog.all,
      params: ActionController::Parameters.new(params)
    ).call
  end
end