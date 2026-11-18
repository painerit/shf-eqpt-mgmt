require "test_helper"

class VerificationSchedulePolicyTest < ActiveSupport::TestCase
  test "admin and metrologist can manage schedules" do
    [users(:admin), users(:metrologist)].each do |user|
      policy = VerificationSchedulePolicy.new(user, verification_schedules(:planned))

      assert policy.index?
      assert policy.create?
      assert policy.update?
      assert policy.approve?
      assert policy.generate?
    end
  end

  test "engineer can read own department schedules only" do
    assert VerificationSchedulePolicy.new(users(:engineer), verification_schedules(:planned)).index?
    assert VerificationSchedulePolicy.new(users(:engineer), verification_schedules(:planned)).show?
    assert_not VerificationSchedulePolicy.new(users(:engineer), verification_schedules(:admin_planned)).show?
    assert_not VerificationSchedulePolicy.new(users(:engineer), verification_schedules(:planned)).create?
  end

  test "customer cannot access schedules" do
    policy = VerificationSchedulePolicy.new(users(:customer), verification_schedules(:planned))

    assert_not policy.index?
    assert_not policy.show?
  end

  test "scope limits engineer to own department" do
    resolved = VerificationSchedulePolicy::Scope.new(users(:engineer), VerificationSchedule.all).resolve

    assert_includes resolved, verification_schedules(:planned)
    assert_not_includes resolved, verification_schedules(:admin_planned)
  end

  test "customer scope is empty" do
    resolved = VerificationSchedulePolicy::Scope.new(users(:customer), VerificationSchedule.all).resolve

    assert_empty resolved
  end
end