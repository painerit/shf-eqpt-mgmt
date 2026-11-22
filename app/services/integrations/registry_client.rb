module Integrations
  class RegistryClient
    class Error < StandardError; end
    class PermanentError < Error; end

    Result = Struct.new(:external_id, :status, keyword_init: true)

    def self.build
      if fake?
        FakeRegistryClient.new
      else
        new(
          base_url: ENV["REGISTRY_API_BASE_URL"],
          token: ENV["REGISTRY_API_TOKEN"]
        )
      end
    end

    def self.fake?
      default = Rails.env.development? || Rails.env.test? ? "true" : "false"
      ENV.fetch("REGISTRY_API_FAKE", default) == "true"
    end

    attr_reader :base_url, :token

    def initialize(base_url:, token: nil)
      @base_url = base_url
      @token = token
    end

    def publish(verification)
      raise Error, "REGISTRY_API_BASE_URL не настроен" if base_url.blank?

      response = connection.post("/api/verifications") do |request|
        request.headers["Authorization"] = "Bearer #{token}" if token.present?
        request.headers["Idempotency-Key"] = "verification-#{verification.id}"
        request.headers["Content-Type"] = "application/json"
        request.body = payload_for(verification).to_json
      end

      handle_response(response)
    rescue Faraday::Error => e
      raise Error, "Ошибка соединения с внешним API: #{e.message}"
    end

    private

    def connection
      @connection ||= Faraday.new(url: base_url) do |builder|
        builder.options.timeout = 10
        builder.options.open_timeout = 5
      end
    end

    def handle_response(response)
      body = parse_body(response.body)

      case response.status
      when 200..299
        Result.new(
          external_id: body&.dig("id"),
          status: body&.dig("status") || "accepted"
        )
      when 429, 500..599
        raise Error, "Внешний API временно недоступен (#{response.status})"
      else
        raise PermanentError, "Внешний API отклонил запрос (#{response.status})"
      end
    end

    def parse_body(body)
      return if body.blank?

      JSON.parse(body)
    rescue JSON::ParserError
      nil
    end

    def payload_for(verification)
      equipment = verification.equipment

      {
        verification_id: verification.id,
        equipment: {
          inventory_number: equipment.inventory_number,
          serial_number: equipment.serial_number,
          model: equipment.model,
          manufacturer: equipment.manufacturer.name,
          department: equipment.department.name
        },
        verification: {
          performed_on: verification.performed_on,
          protocol_number: verification.protocol_number,
          certificate_number: verification.certificate_number,
          status: verification.status,
          conclusion: verification.conclusion
        },
        results: verification.verification_results.map do |result|
          {
            parameter_name: result.parameter_name,
            unit: result.unit,
            measured_value: result.measured_value,
            reference_value: result.reference_value,
            tolerance: result.tolerance,
            passed: result.passed
          }
        end
      }
    end
  end
end