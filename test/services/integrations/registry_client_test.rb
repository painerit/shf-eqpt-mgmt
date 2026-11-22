require "test_helper"
require "webmock/minitest"

class Integrations::RegistryClientTest < ActiveSupport::TestCase
  setup do
    @verification = verifications(:passed)
    @url = "https://registry.example.test/api/verifications"
    @client = Integrations::RegistryClient.new(
      base_url: "https://registry.example.test",
      token: "secret-token"
    )
  end

  test "publishes verification with authorization and idempotency headers" do
    stub_request(:post, @url)
      .to_return(
        status: 200,
        body: { id: "REG-000001", status: "accepted" }.to_json,
        headers: { "Content-Type" => "application/json" }
      )

    result = @client.publish(@verification)

    assert_equal "REG-000001", result.external_id
    assert_equal "accepted", result.status
    assert_requested(:post, @url) do |request|
      body = JSON.parse(request.body)
      request.headers["Authorization"] == "Bearer secret-token" &&
        request.headers["Idempotency-Key"] == "verification-#{@verification.id}" &&
        body["verification_id"] == @verification.id &&
        body.dig("equipment", "inventory_number") == @verification.equipment.inventory_number
    end
  end

  test "raises temporary error for server error" do
    stub_request(:post, @url).to_return(status: 500, body: "internal error")

    assert_raises Integrations::RegistryClient::Error do
      @client.publish(@verification)
    end
  end

  test "raises permanent error for client error" do
    stub_request(:post, @url).to_return(status: 422, body: "invalid payload")

    assert_raises Integrations::RegistryClient::PermanentError do
      @client.publish(@verification)
    end
  end

  test "raises temporary error on timeout" do
    stub_request(:post, @url).to_timeout

    assert_raises Integrations::RegistryClient::Error do
      @client.publish(@verification)
    end
  end

  test "requires base url" do
    client = Integrations::RegistryClient.new(base_url: nil)

    assert_raises Integrations::RegistryClient::Error do
      client.publish(@verification)
    end
  end
end