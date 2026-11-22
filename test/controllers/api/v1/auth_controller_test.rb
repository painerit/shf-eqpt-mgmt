require "test_helper"

class Api::V1::AuthControllerTest < ActionDispatch::IntegrationTest
  test "returns token for valid credentials" do
    post api_v1_auth_login_path, params: {
      email: users(:engineer).email,
      password: "password123"
    }

    assert_response :success
    body = response.parsed_body
    assert body["token"].present?
    assert_equal "Bearer", body["token_type"]
    assert_equal users(:engineer).email, body.dig("user", "email")
  end

  test "rejects invalid credentials" do
    post api_v1_auth_login_path, params: {
      email: users(:engineer).email,
      password: "wrong-password"
    }

    assert_response :unauthorized
    assert_equal "unauthorized", response.parsed_body.dig("error", "code")
  end

  test "rejects inactive user" do
    users(:engineer).update!(active: false)

    post api_v1_auth_login_path, params: {
      email: users(:engineer).email,
      password: "password123"
    }

    assert_response :unauthorized
  end
end