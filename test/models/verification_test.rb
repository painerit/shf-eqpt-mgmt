require "test_helper"

class VerificationTest < ActiveSupport::TestCase
  test "passed verification requires certificate number" do
    verification = verifications(:passed).dup
    verification.certificate_number = nil

    assert_not verification.valid?
    assert verification.errors[:certificate_number].any?
  end

  test "failed verification cannot have certificate number" do
    verification = verifications(:failed).dup
    verification.certificate_number = "SV-TEST-000003"

    assert_not verification.valid?
    assert verification.errors[:certificate_number].any?
  end

  test "completed verification requires performed date" do
    verification = verifications(:passed).dup
    verification.performed_on = nil

    assert_not verification.valid?
    assert verification.errors[:performed_on].any?
  end

  test "schedule must belong to the same equipment" do
    verification = Verification.new(
      equipment: equipment(:generator),
      verification_schedule: verification_schedules(:overdue),
      status: "planned"
    )

    assert_not verification.valid?
    assert verification.errors[:verification_schedule].any?
  end

  test "completed scope includes passed and failed" do
    assert_includes Verification.completed, verifications(:passed)
    assert_includes Verification.completed, verifications(:failed)
  end
end