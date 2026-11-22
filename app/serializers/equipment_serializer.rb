class EquipmentSerializer
  def self.call(equipment)
    {
      id: equipment.id,
      inventory_number: equipment.inventory_number,
      serial_number: equipment.serial_number,
      model: equipment.model,
      status: equipment.status,
      status_label: I18n.t("enums.equipment.status.#{equipment.status}"),
      equipment_type: reference(equipment.equipment_type),
      manufacturer: reference(equipment.manufacturer),
      department: reference(equipment.department),
      responsible_user: user(equipment.responsible_user),
      commissioned_on: equipment.commissioned_on,
      verification_interval_months: equipment.verification_interval_months,
      last_verified_on: equipment.last_verified_on,
      next_verification_on: equipment.next_verification_on,
      next_verification_in_days: equipment.next_verification_in_days,
      overdue: equipment.overdue?,
      due_soon: equipment.due_soon?,
      location: equipment.location,
      notes: equipment.notes,
      created_at: equipment.created_at,
      updated_at: equipment.updated_at
    }
  end

  def self.reference(record)
    return nil if record.blank?

    { id: record.id, name: record.name }
  end

  def self.user(record)
    return nil if record.blank?

    {
      id: record.id,
      full_name: record.full_name,
      email: record.email,
      role: record.role&.name
    }
  end

  private_class_method :reference, :user
end