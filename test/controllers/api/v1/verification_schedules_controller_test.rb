require "test_helper"

class Api::V1::VerificationSchedulesControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get api_v1_verification_schedules_path

    assert_response :unauthorized
  end

  test "admin receives schedules with pagination" do
    get api_v1_verification_schedules_path, headers: api_auth_headers(users(:admin))

    assert_response :success
    body = response.parsed_body
    equipment_numbers = body.fetch("data").map { |item| item.dig("equipment", "inventory_number") }

    assert_includes equipment_numbers, "INV-TEST-001"
    assert_includes equipment_numbers, "INV-TEST-003"
    assert_equal 1, body.dig("meta", "page")
  end

  test "engineer receives only own department schedules" do
    get api_v1_verification_schedules_path, headers: api_auth_headers(users(:engineer))

    assert_response :success
    equipment_numbers = response.parsed_body.fetch("data").map { |item| item.dig("equipment", "inventory_number") }

    assert_includes equipment_numbers, "INV-TEST-001"
    assert_not_includes equipment_numbers, "INV-TEST-003"
  end

  test "customer cannot access schedules" do
    get api_v1_verification_schedules_path, headers: api_auth_headers(users(:customer))

    assert_response :forbidden
    assert_equal "forbidden", response.parsed_body.dig("error", "code")
  end

  test "filters schedules by year and status" do
    get api_v1_verification_schedules_path,
        params: { period_year: 2027, status: "planned" },
        headers: api_auth_headers(users(:admin))

    assert_response :success
    data = response.parsed_body.fetch("data")

    assert_equal 2, data.length
    assert data.all? { |item| item["period_year"] == 2027 }
    assert data.all? { |item| item["status"] == "planned" }
  end
end