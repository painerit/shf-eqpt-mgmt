require "test_helper"

class Api::V1::VerificationsControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get api_v1_verifications_path

    assert_response :unauthorized
  end

  test "admin receives all verifications" do
    get api_v1_verifications_path, headers: api_auth_headers(users(:admin))

    assert_response :success
    body = response.parsed_body
    statuses = body.fetch("data").map { |item| item["status"] }

    assert_includes statuses, "passed"
    assert_includes statuses, "in_progress"
    assert_equal 1, body.dig("meta", "page")
  end

  test "customer receives only completed verifications" do
    get api_v1_verifications_path, headers: api_auth_headers(users(:customer))

    assert_response :success
    statuses = response.parsed_body.fetch("data").map { |item| item["status"] }

    assert statuses.all? { |status| %w[passed failed].include?(status) }
    assert_includes statuses, "passed"
    assert_includes statuses, "failed"
  end

  test "filters verifications by status" do
    get api_v1_verifications_path,
        params: { status: "failed" },
        headers: api_auth_headers(users(:admin))

    assert_response :success
    data = response.parsed_body.fetch("data")

    assert data.all? { |item| item["status"] == "failed" }
  end

  test "shows verification with measurement results" do
    get api_v1_verification_path(verifications(:passed)), headers: api_auth_headers(users(:admin))

    assert_response :success
    data = response.parsed_body.fetch("data")

    assert_equal "PR-TEST-000001", data["protocol_number"]
    assert_equal "SV-TEST-000001", data["certificate_number"]
    assert_kind_of Array, data["results"]
    assert_equal "Выходная мощность", data["results"].first["parameter_name"]
  end

  test "customer cannot see draft verification" do
    get api_v1_verification_path(verifications(:draft)), headers: api_auth_headers(users(:customer))

    assert_response :forbidden
  end

  test "returns not found for unknown verification" do
    get api_v1_verification_path(999_999), headers: api_auth_headers(users(:admin))

    assert_response :not_found
  end
end