require "test_helper"

class JsonWebTokenTest < ActiveSupport::TestCase
  test "encodes and decodes payload" do
    token = JsonWebToken.encode({ user_id: users(:engineer).id })
    payload = JsonWebToken.decode(token)

    assert_equal users(:engineer).id, payload[:user_id]
    assert payload[:exp].present?
  end

  test "returns nil for expired token" do
    token = JsonWebToken.encode({ user_id: users(:engineer).id }, exp: 1.hour.ago)

    assert_nil JsonWebToken.decode(token)
  end

  test "returns nil for malformed token" do
    assert_nil JsonWebToken.decode("not-a-jwt")
    assert_nil JsonWebToken.decode(nil)
  end
end