require "test_helper"

module Verifications
  class CompleteTest < ActiveSupport::TestCase
    test "completes passed verification and updates equipment dates" do
      verification = build_verification

      result = Verifications::Complete.new(
        verification: verification,
        user: users(:engineer),
        attributes: attributes(passed: true)
      ).call

      assert_equal "passed", result.status
      assert_equal "PR-2026-000001", result.protocol_number
      assert_equal "SV-2026-000001", result.certificate_number
      assert_equal Date.new(2027, 11, 20), equipment(:generator).reload.next_verification_on
      assert_equal "completed", verification_schedules(:planned).reload.status
      assert_equal "complete", result.audit_logs.last.action
      assert_equal 1, DocumentCounter.find_by!(kind: "verification", year: 2026).value
      assert_enqueued_with(job: PublishVerificationJob, args: [result.id])
    end

    test "completes failed verification without certificate" do
      verification = build_verification

      result = Verifications::Complete.new(
        verification: verification,
        user: users(:engineer),
        attributes: attributes(passed: false)
      ).call

      assert_equal "failed", result.status
      assert_nil result.certificate_number
      assert_equal Date.new(2026, 12, 20), equipment(:generator).reload.next_verification_on
    end

    test "rolls back document counter and equipment changes on validation error" do
      verification = build_verification

      assert_raises ActiveRecord::RecordInvalid do
        Verifications::Complete.new(
          verification: verification,
          user: users(:engineer),
          attributes: attributes(passed: true, parameter_name: "")
        ).call
      end

      assert_equal 0, DocumentCounter.find_by!(kind: "verification", year: 2026).value
      assert_equal Date.new(2027, 1, 15), equipment(:generator).reload.next_verification_on
      assert_not AuditLog.where(auditable: verification, action: "complete").exists?
    end

    test "requires at least one measurement result" do
      verification = build_verification

      error = assert_raises ActiveRecord::RecordInvalid do
        Verifications::Complete.new(
          verification: verification,
          user: users(:engineer),
          attributes: empty_attributes
        ).call
      end

      assert_includes error.record.errors[:base], "Добавьте хотя бы один результат измерения"
    end

    private

    def build_verification
      Verification.create!(
        equipment: equipment(:generator),
        verification_schedule: verification_schedules(:planned),
        performed_by: users(:engineer),
        performed_on: Date.new(2026, 11, 20),
        status: "in_progress"
      )
    end

    def attributes(passed:, parameter_name: "Выходная мощность")
      ActionController::Parameters.new(
        performed_on: "2026-11-20",
        conclusion: passed ? "Оборудование пригодно" : "Оборудование непригодно",
        verification_results_attributes: {
          "0" => {
            parameter_name: parameter_name,
            unit: "Вт",
            measured_value: passed ? 10.0 : 12.0,
            reference_value: 10.0,
            tolerance: 0.5,
            passed: passed
          }
        }
      ).permit!
    end

    def empty_attributes
      ActionController::Parameters.new(
        performed_on: "2026-11-20",
        conclusion: "Без результатов"
      ).permit!
    end
  end
end