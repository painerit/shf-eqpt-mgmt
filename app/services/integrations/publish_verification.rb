module Integrations
  class PublishVerification
    def initialize(verification, client: nil)
      @verification = verification
      @client = client || RegistryClient.build
    end

    def call
      result = client.publish(verification)

      verification.update!(
        external_id: result.external_id,
        external_status: result.status,
        external_synced_at: Time.current,
        external_error: nil
      )
      record_audit

      result
    rescue RegistryClient::PermanentError => e
      mark_failed(e)
      nil
    rescue RegistryClient::Error => e
      mark_failed(e)
      raise
    end

    private

    attr_reader :verification, :client

    def mark_failed(error)
      verification.update!(
        external_status: "failed",
        external_error: error.message,
        external_synced_at: Time.current
      )
      record_audit
    end

    def record_audit
      AuditLog.record!(
        auditable: verification,
        user: Current.user,
        action: "publish",
        audited_changes: verification.saved_changes,
        ip_address: Current.request_ip,
        user_agent: Current.user_agent
      )
    end
  end
end