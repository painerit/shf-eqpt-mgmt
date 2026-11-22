class VerificationScheduleSerializer
  def self.call(schedule)
    {
      id: schedule.id,
      planned_on: schedule.planned_on,
      period_year: schedule.period_year,
      status: schedule.status,
      status_label: I18n.t("enums.verification_schedule.status.#{schedule.status}"),
      equipment: equipment(schedule.equipment),
      responsible_user: user(schedule.responsible_user),
      normative_document: normative_document(schedule.normative_document),
      notes: schedule.notes,
      created_at: schedule.created_at,
      updated_at: schedule.updated_at
    }
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

  def self.normative_document(record)
    return nil if record.blank?

    {
      id: record.id,
      doc_number: record.doc_number,
      title: record.title
    }
  end

  private_class_method :equipment, :user, :normative_document
end