require "test_helper"

class VerificationSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get verification_schedules_path

    assert_redirected_to login_path
  end

  test "customer cannot access schedules" do
    sign_in_as users(:customer)

    get verification_schedules_path

    assert_redirected_to root_path
  end

  test "engineer sees only own department schedules" do
    sign_in_as users(:engineer)

    get verification_schedules_path

    assert_response :success
    assert_match "INV-TEST-001", response.body
    assert_no_match "INV-TEST-003", response.body
  end

  test "admin creates schedule and writes audit log" do
    sign_in_as users(:admin)

    assert_difference("VerificationSchedule.count", 1) do
      assert_difference("AuditLog.where(action: 'create').count", 1) do
        post verification_schedules_path, params: {
          verification_schedule: {
            equipment_id: equipment(:future_generator).id,
            planned_on: "2029-01-01",
            normative_document_id: normative_documents(:gost_power).id,
            responsible_user_id: users(:engineer).id,
            status: "planned",
            notes: "План на 2029 год"
          }
        }
      end
    end

    schedule = VerificationSchedule.find_by!(
      equipment: equipment(:future_generator),
      planned_on: Date.new(2029, 1, 1)
    )
    assert_equal 2029, schedule.period_year
    assert_redirected_to verification_schedule_path(schedule)
  end

  test "engineer cannot create schedule" do
    sign_in_as users(:engineer)

    assert_no_difference("VerificationSchedule.count") do
      post verification_schedules_path, params: {
        verification_schedule: {
          equipment_id: equipment(:future_generator).id,
          planned_on: "2029-01-01",
          status: "planned"
        }
      }
    end

    assert_redirected_to root_path
  end

  test "admin approves schedule" do
    sign_in_as users(:admin)
    schedule = verification_schedules(:planned)

    patch approve_verification_schedule_path(schedule)

    assert_redirected_to verification_schedule_path(schedule)
    assert_equal "approved", schedule.reload.status
  end

  test "admin generates schedule for year" do
    sign_in_as users(:admin)

    assert_difference("VerificationSchedule.count", 1) do
      post generate_verification_schedules_path, params: {
        period_year: 2028,
        department_id: departments(:svc).id
      }
    end

    assert_redirected_to verification_schedules_path
    assert VerificationSchedule.exists?(
      equipment: equipment(:future_generator),
      planned_on: Date.new(2028, 6, 1)
    )
  end

  test "show page displays schedule details" do
    sign_in_as users(:admin)

    get verification_schedule_path(verification_schedules(:planned))

    assert_response :success
    assert_select "h1", "INV-TEST-001"
    assert_match "Проведение поверки", response.body
  end
end