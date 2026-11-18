require "test_helper"

class VerificationPolicyTest < ActiveSupport::TestCase
  test "engineer can create verification for own department equipment" do
    verification = Verification.new(
      equipment: equipment(:generator),
      verification_schedule: verification_schedules(:planned)
    )

    assert VerificationPolicy.new(users(:engineer), verification).create?
  end

  test "engineer cannot create verification for another department" do
    verification = Verification.new(
      equipment: equipment(:admin_generator),
      verification_schedule: verification_schedules(:admin_planned)
    )

    assert_not VerificationPolicy.new(users(:engineer), verification).create?
  end

  test "customer cannot create verification" do
    verification = Verification.new(
      equipment: equipment(:generator),
      verification_schedule: verification_schedules(:planned)
    )

    assert_not VerificationPolicy.new(users(:customer), verification).create?
  end

  test "engineer can work on assigned draft verification" do
    policy = VerificationPolicy.new(users(:engineer), verifications(:draft))

    assert policy.show?
    assert policy.update?
    assert policy.start?
    assert policy.complete?
  end

  test "engineer cannot work on completed verification" do
    policy = VerificationPolicy.new(users(:engineer), verifications(:passed))

    assert policy.show?
    assert_not policy.update?
    assert_not policy.complete?
  end

  test "engineer cannot read verification from another department" do
    assert_not VerificationPolicy.new(users(:engineer), verifications(:admin_passed)).show?
  end

  test "customer sees only completed verification of own department" do
    assert VerificationPolicy.new(users(:customer), verifications(:passed)).show?
    assert_not VerificationPolicy.new(users(:customer), verifications(:draft)).show?
  end

  test "customer scope contains only completed verification" do
    resolved = VerificationPolicy::Scope.new(users(:customer), Verification.all).resolve

    assert_includes resolved, verifications(:passed)
    assert_includes resolved, verifications(:failed)
    assert_not_includes resolved, verifications(:draft)
    assert_not_includes resolved, verifications(:admin_passed)
  end

  test "engineer scope is limited to own department" do
    resolved = VerificationPolicy::Scope.new(users(:engineer), Verification.all).resolve

    assert_includes resolved, verifications(:draft)
    assert_includes resolved, verifications(:passed)
    assert_not_includes resolved, verifications(:admin_passed)
  end
end