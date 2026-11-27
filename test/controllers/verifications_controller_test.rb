require "test_helper"

class VerificationsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get verifications_path

    assert_redirected_to login_path
  end

  test "admin sees all verifications" do
    sign_in_as users(:admin)

    get verifications_path

    assert_response :success
    assert_match "INV-TEST-001", response.body
    assert_match "INV-TEST-003", response.body
  end

  test "engineer sees only own department verifications" do
    sign_in_as users(:engineer)

    get verifications_path

    assert_response :success
    assert_match "INV-TEST-001", response.body
    assert_no_match "INV-TEST-003", response.body
  end

  test "customer sees only completed verifications" do
    sign_in_as users(:customer)

    get verifications_path

    assert_response :success
    assert_match "INV-TEST-001", response.body
    assert_match "INV-TEST-002", response.body
    assert_no_match "INV-TEST-003", response.body
  end

  test "engineer starts verification from schedule" do
    sign_in_as users(:engineer)

    assert_difference("Verification.count", 1) do
      post verifications_path, params: {
        verification: { verification_schedule_id: verification_schedules(:planned).id }
      }
    end

    verification = Verification.order(:id).last
    assert_equal "in_progress", verification.status
    assert_equal users(:engineer), verification.performed_by
    assert_redirected_to edit_verification_path(verification)
  end

  test "engineer cannot start verification for another department" do
    sign_in_as users(:engineer)

    assert_no_difference("Verification.count") do
      post verifications_path, params: {
        verification: { verification_schedule_id: verification_schedules(:admin_planned).id }
      }
    end

    assert_redirected_to root_path
  end

  test "engineer updates draft verification" do
    sign_in_as users(:engineer)
    verification = verifications(:draft)

    patch verification_path(verification), params: {
      verification: {
        performed_on: "2026-11-02",
        conclusion: "Черновик заполнен",
        verification_results_attributes: {
          "0" => {
            parameter_name: "Выходная мощность",
            unit: "Вт",
            measured_value: "10.0",
            reference_value: "10.0",
            tolerance: "0.5",
            passed: "true"
          }
        }
      }
    }

    assert_redirected_to edit_verification_path(verification)
    assert_equal "Черновик заполнен", verification.reload.conclusion
    assert_equal 1, verification.verification_results.count
  end

  test "engineer completes verification" do
    sign_in_as users(:engineer)
    verification = verifications(:draft)

    patch complete_verification_path(verification), params: {
      verification: {
        performed_on: "2026-11-20",
        conclusion: "Оборудование пригодно",
        verification_results_attributes: {
          "0" => {
            parameter_name: "Выходная мощность",
            unit: "Вт",
            measured_value: "10.0",
            reference_value: "10.0",
            tolerance: "0.5",
            passed: "true"
          }
        }
      }
    }

    assert_redirected_to verification_path(verification)
    verification.reload
    assert_equal "passed", verification.status
    assert_equal "PR-2026-000001", verification.protocol_number
    assert_equal "SV-2026-000001", verification.certificate_number
    assert_equal Date.new(2027, 11, 20), equipment(:generator).reload.next_verification_on
  end

  test "engineer completes verification through the edit form commit action" do
    sign_in_as users(:engineer)
    verification = verifications(:draft)

    patch verification_path(verification), params: {
      commit_action: "complete",
      verification: {
        performed_on: "2026-11-21",
        conclusion: "Оборудование пригодно",
        verification_results_attributes: {
          "0" => {
            parameter_name: "Выходная мощность",
            unit: "Вт",
            measured_value: "10.0",
            reference_value: "10.0",
            tolerance: "0.5",
            passed: "true"
          }
        }
      }
    }

    assert_redirected_to verification_path(verification)
    assert_equal "passed", verification.reload.status
    assert_equal "PR-2026-000001", verification.protocol_number
  end

  test "failed result completes verification without certificate" do
    sign_in_as users(:engineer)
    verification = verifications(:draft)

    patch complete_verification_path(verification), params: {
      verification: {
        performed_on: "2026-11-20",
        conclusion: "Оборудование непригодно",
        verification_results_attributes: {
          "0" => {
            parameter_name: "Выходная мощность",
            unit: "Вт",
            measured_value: "12.0",
            reference_value: "10.0",
            tolerance: "0.5",
            passed: "false"
          }
        }
      }
    }

    assert_redirected_to verification_path(verification)
    verification.reload
    assert_equal "failed", verification.status
    assert_nil verification.certificate_number
  end

  test "protocol PDF is generated" do
    sign_in_as users(:admin)

    get protocol_verification_path(verifications(:passed), format: :pdf)

    assert_response :success
    assert_equal "application/pdf", response.media_type
    assert response.body.start_with?("%PDF")
  end

  test "customer can view completed verification" do
    sign_in_as users(:customer)

    get verification_path(verifications(:passed))

    assert_response :success
    assert_select "h1", "PR-TEST-000001"
  end

  test "customer cannot view draft verification" do
    sign_in_as users(:customer)

    get verification_path(verifications(:draft))

    assert_redirected_to root_path
  end

  test "admin cancels planned verification" do
    sign_in_as users(:admin)
    verification = verifications(:draft)

    patch cancel_verification_path(verification)

    assert_redirected_to verification_path(verification)
    assert_equal "canceled", verification.reload.status
  end

  test "admin enqueues external publication" do
    sign_in_as users(:admin)
    verification = verifications(:passed)

    assert_enqueued_with(job: PublishVerificationJob, args: [verification.id]) do
      post publish_verification_path(verification)
    end

    assert_redirected_to verification_path(verification)
  end

  test "engineer cannot publish verification" do
    sign_in_as users(:engineer)
    verification = verifications(:passed)

    post publish_verification_path(verification)

    assert_redirected_to root_path
  end
end