module Verifications
  class Complete
    def initialize(verification:, user:, attributes:)
      @verification = verification
      @user = user
      @attributes = attributes
    end

    def call
      with_transaction do
        verification.lock!

        if verification.completed?
          verification.errors.add(:base, "Поверка уже завершена")
          raise ActiveRecord::RecordInvalid.new(verification)
        end

        verification.assign_attributes(attributes)
        verification.performed_by ||= user
        verification.performed_on ||= Date.current

        results = verification.verification_results.reject(&:marked_for_destruction?)
        if results.empty?
          verification.errors.add(:base, "Добавьте хотя бы один результат измерения")
          raise ActiveRecord::RecordInvalid.new(verification)
        end

        verification.status = results.all?(&:passed?) ? "passed" : "failed"
        verification.completed_at = Time.current

        assign_document_numbers
        verification.save!

        verification.equipment.apply_verification_result!(
          performed_on: verification.performed_on,
          passed: verification.passed?
        )

        verification.verification_schedule&.update!(status: "completed")

        AuditLog.record!(
          auditable: verification,
          user: user,
          action: "complete",
          audited_changes: verification.saved_changes,
          ip_address: Current.request_ip,
          user_agent: Current.user_agent
        )

        verification
      end

      PublishVerificationJob.perform_later(verification.id)
      verification
    end

    private

    attr_reader :verification, :user, :attributes

    def with_transaction(&block)
      if ActiveRecord::Base.connection.transaction_open?
        ActiveRecord::Base.transaction(requires_new: true, &block)
      else
        ActiveRecord::Base.transaction(isolation: :read_committed, &block)
      end
    end

    def assign_document_numbers
      needs_sequence = verification.protocol_number.blank? ||
                       (verification.passed? && verification.certificate_number.blank?)

      if needs_sequence
        @sequence = DocumentCounter.next_value!(
          kind: "verification",
          year: verification.performed_on.year
        )
      end

      year = verification.performed_on.year
      verification.protocol_number ||= format("PR-%d-%06d", year, @sequence)
      verification.certificate_number =
        if verification.passed?
          verification.certificate_number || format("SV-%d-%06d", year, @sequence)
        end
    end
  end
end