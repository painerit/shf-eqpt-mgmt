require "test_helper"

class Integrations::PublishVerificationTest < ActiveSupport::TestCase
  test "stores external id and status on success" do
    verification = verifications(:passed)

    result = Integrations::PublishVerification.new(
      verification,
      client: SuccessClient.new
    ).call

    verification.reload
    assert_equal "REG-000001", result.external_id
    assert_equal "REG-000001", verification.external_id
    assert_equal "accepted", verification.external_status
    assert_nil verification.external_error
    assert_not_nil verification.external_synced_at
    assert AuditLog.where(auditable: verification, action: "publish").exists?
  end

  test "marks permanent failure without raising" do
    verification = verifications(:passed)

    result = Integrations::PublishVerification.new(
      verification,
      client: PermanentFailureClient.new
    ).call

    verification.reload
    assert_nil result
    assert_equal "failed", verification.external_status
    assert_equal "Внешний API отклонил запрос", verification.external_error
    assert AuditLog.where(auditable: verification, action: "publish").exists?
  end

  test "marks temporary failure and re-raises for job retry" do
    verification = verifications(:passed)

    assert_raises Integrations::RegistryClient::Error do
      Integrations::PublishVerification.new(
        verification,
        client: TransientFailureClient.new
      ).call
    end

    verification.reload
    assert_equal "failed", verification.external_status
    assert_equal "Внешний API временно недоступен", verification.external_error
  end

  class SuccessClient
    def publish(_verification)
      Integrations::RegistryClient::Result.new(
        external_id: "REG-000001",
        status: "accepted"
      )
    end
  end

  class PermanentFailureClient
    def publish(_verification)
      raise Integrations::RegistryClient::PermanentError, "Внешний API отклонил запрос"
    end
  end

  class TransientFailureClient
    def publish(_verification)
      raise Integrations::RegistryClient::Error, "Внешний API временно недоступен"
    end
  end
end