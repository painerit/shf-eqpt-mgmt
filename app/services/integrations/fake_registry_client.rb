module Integrations
  class FakeRegistryClient
    def publish(verification)
      if ENV["REGISTRY_API_FAKE_FAIL"] == "true"
        raise RegistryClient::Error, "Тестовый сбой внешнего API"
      end

      RegistryClient::Result.new(
        external_id: "FAKE-#{verification.id.to_s.rjust(6, "0")}",
        status: "accepted"
      )
    end
  end
end