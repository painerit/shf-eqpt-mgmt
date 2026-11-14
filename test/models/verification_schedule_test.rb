require "test_helper"

class VerificationScheduleTest < ActiveSupport::TestCase
  test "period year is derived from planned date" do
    schedule = VerificationSchedule.new(
      equipment: equipment(:generator),
      planned_on: Date.new(2028, 5, 20),
      status: "planned"
    )

    assert schedule.valid?
    assert_equal 2028, schedule.period_year
  end

  test "planned date is unique per equipment" do
    duplicate = verification_schedules(:planned).dup

    assert_not duplicate.valid?
    assert duplicate.errors[:planned_on].any?
  end

  test "period year must match planned date" do
    schedule = verification_schedules(:planned).dup
    schedule.planned_on = Date.new(2028, 1, 1)
    schedule.period_year = 2027

    assert_not schedule.valid?
    assert schedule.errors[:period_year].any?
  end
end