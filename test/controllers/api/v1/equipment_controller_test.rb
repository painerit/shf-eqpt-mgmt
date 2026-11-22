require "test_helper"

class Api::V1::EquipmentControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get api_v1_equipment_index_path

    assert_response :unauthorized
    assert_equal "unauthorized", response.parsed_body.dig("error", "code")
  end

  test "admin receives all equipment with pagination meta" do
    get api_v1_equipment_index_path, headers: api_auth_headers(users(:admin))

    assert_response :success
    body = response.parsed_body
    inventory_numbers = body.fetch("data").map { |item| item["inventory_number"] }

    assert_includes inventory_numbers, "INV-TEST-001"
    assert_includes inventory_numbers, "INV-TEST-003"
    assert_equal 1, body.dig("meta", "page")
    assert_equal 20, body.dig("meta", "per_page")
  end

  test "engineer receives only own department equipment" do
    get api_v1_equipment_index_path, headers: api_auth_headers(users(:engineer))

    assert_response :success
    inventory_numbers = response.parsed_body.fetch("data").map { |item| item["inventory_number"] }

    assert_includes inventory_numbers, "INV-TEST-001"
    assert_not_includes inventory_numbers, "INV-TEST-003"
  end

  test "customer receives only in-service equipment of own department" do
    get api_v1_equipment_index_path, headers: api_auth_headers(users(:customer))

    assert_response :success
    inventory_numbers = response.parsed_body.fetch("data").map { |item| item["inventory_number"] }

    assert_includes inventory_numbers, "INV-TEST-001"
    assert_not_includes inventory_numbers, "INV-TEST-003"
    assert_not_includes inventory_numbers, "INV-TEST-004"
  end

  test "filters equipment by search query" do
    get api_v1_equipment_index_path,
        params: { q: "SN-TEST-002" },
        headers: api_auth_headers(users(:admin))

    assert_response :success
    inventory_numbers = response.parsed_body.fetch("data").map { |item| item["inventory_number"] }

    assert_equal ["INV-TEST-002"], inventory_numbers
  end

  test "filters overdue equipment" do
    get api_v1_equipment_index_path,
        params: { due: "overdue" },
        headers: api_auth_headers(users(:admin))

    assert_response :success
    inventory_numbers = response.parsed_body.fetch("data").map { |item| item["inventory_number"] }

    assert_includes inventory_numbers, "INV-TEST-002"
    assert_not_includes inventory_numbers, "INV-TEST-001"
    assert_not_includes inventory_numbers, "INV-TEST-004"
  end

  test "shows equipment details with recent verifications" do
    get api_v1_equipment_path(equipment(:generator)), headers: api_auth_headers(users(:admin))

    assert_response :success
    data = response.parsed_body.fetch("data")

    assert_equal "INV-TEST-001", data["inventory_number"]
    assert_equal "Генератор СВЧ", data.dig("equipment_type", "name")
    assert_kind_of Array, data["recent_verifications"]
  end

  test "customer cannot see equipment from another department" do
    get api_v1_equipment_path(equipment(:admin_generator)), headers: api_auth_headers(users(:customer))

    assert_response :forbidden
    assert_equal "forbidden", response.parsed_body.dig("error", "code")
  end

  test "returns not found for unknown equipment" do
    get api_v1_equipment_path(999_999), headers: api_auth_headers(users(:admin))

    assert_response :not_found
  end

  test "returns equipment verification history" do
    get verifications_api_v1_equipment_path(equipment(:generator)),
        headers: api_auth_headers(users(:admin))

    assert_response :success
    body = response.parsed_body
    statuses = body.fetch("data").map { |item| item["status"] }

    assert_includes statuses, "passed"
    assert_includes statuses, "in_progress"
    assert body["meta"].present?
  end
end