require "test_helper"

class VerificationScheduleQueryTest < ActiveSupport::TestCase
  test "filters by year" do
    result = query(period_year: 2027)

    assert_includes result, verification_schedules(:planned)
    assert_includes result, verification_schedules(:admin_planned)
    assert_not_includes result, verification_schedules(:overdue)
  end

  test "filters by status" do
    result = query(status: "planned")

    assert_includes result, verification_schedules(:planned)
    assert_includes result, verification_schedules(:overdue)
  end

  test "filters by department through equipment" do
    result = query(department_id: departments(:svc).id)

    assert_includes result, verification_schedules(:planned)
    assert_not_includes result, verification_schedules(:admin_planned)
  end

  test "searches by equipment inventory number" do
    result = query(q: "INV-TEST-003")

    assert_includes result, verification_schedules(:admin_planned)
    assert_not_includes result, verification_schedules(:planned)
  end

  test "ignores unsupported status" do
    result = query(status: "unknown")

    assert_includes result, verification_schedules(:planned)
  end

  private

  def query(params = {})
    VerificationScheduleQuery.new(
      scope: VerificationSchedule.all,
      params: ActionController::Parameters.new(params)
    ).call
  end
end