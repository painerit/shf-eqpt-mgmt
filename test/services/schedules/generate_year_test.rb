require "test_helper"

module Schedules
  class GenerateYearTest < ActiveSupport::TestCase
    test "creates schedule for equipment due in selected year" do
      result = Schedules::GenerateYear.new(
        year: 2028,
        department_id: departments(:svc).id
      ).call

      assert_equal 1, result.created
      assert_equal 0, result.skipped

      schedule = VerificationSchedule.find_by!(
        equipment: equipment(:future_generator),
        planned_on: Date.new(2028, 6, 1)
      )
      assert_equal 2028, schedule.period_year
      assert_equal "planned", schedule.status
      assert_equal users(:engineer), schedule.responsible_user
    end

    test "is idempotent for repeated generation" do
      Schedules::GenerateYear.new(year: 2028, department_id: departments(:svc).id).call

      result = Schedules::GenerateYear.new(
        year: 2028,
        department_id: departments(:svc).id
      ).call

      assert_equal 0, result.created
      assert_equal 1, result.skipped
      assert_equal 1, VerificationSchedule.where(
        equipment: equipment(:future_generator),
        planned_on: Date.new(2028, 6, 1)
      ).count
    end

    test "ignores decommissioned equipment" do
      result = Schedules::GenerateYear.new(
        year: 2025,
        department_id: departments(:svc).id
      ).call

      assert_equal 0, result.created
      assert_not VerificationSchedule.exists?(equipment: equipment(:decommissioned_generator))
    end

    test "rejects invalid year" do
      assert_raises ArgumentError do
        Schedules::GenerateYear.new(year: 0).call
      end
    end
  end
end