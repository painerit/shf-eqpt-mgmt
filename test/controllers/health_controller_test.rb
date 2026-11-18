require "test_helper"

class HealthControllerTest < ActionDispatch::IntegrationTest
  test "returns ok when database is available" do
    get health_check_path

    assert_response :success
    assert_equal "ok", response.parsed_body["status"]
  end
end