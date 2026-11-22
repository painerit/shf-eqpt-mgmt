class VerificationSerializer
  def self.call(verification, include_results: false)
    payload = {
      id: verification.id,
      equipment_id: verification.equipment_id,
      equipment: equipment(verification.equipment),
      verification_schedule_id: verification.verification_schedule_id,
      status: verification.status,
      status_label: I18n.t("enums.verification.status.#{verification.status}"),
      performed_on: verification.performed_on,
      completed_at: verification.completed_at,
      performed_by: user(verification.performed_by),
      protocol_number: verification.protocol_number,
      certificate_number: verification.certificate_number,
      conclusion: verification.conclusion,
      external_id: verification.external_id,
      external_status: verification.external_status,
      external_synced_at: verification.external_synced_at,
      created_at: verification.created_at,
      updated_at: verification.updated_at
    }

    payload[:results] = verification.verification_results.map { |item| result_payload(item) } if include_results
    payload
  end

  def self.equipment(record)
    return nil if record.blank?

    {
      id: record.id,
      inventory_number: record.inventory_number,
      serial_number: record.serial_number,
      model: record.model,
      department_id: record.department_id
    }
  end

  def self.user(record)
    return nil if record.blank?

    {
      id: record.id,
      full_name: record.full_name,
      email: record.email
    }
  end

  def self.result_payload(record)
    {
      id: record.id,
      parameter_name: record.parameter_name,
      unit: record.unit,
      measured_value: record.measured_value,
      reference_value: record.reference_value,
      tolerance: record.tolerance,
      passed: record.passed,
      measured_at: record.measured_at
    }
  end

  private_class_method :equipment, :user, :result_payload
end