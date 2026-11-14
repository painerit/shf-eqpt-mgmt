require "test_helper"

class EquipmentTest < ActiveSupport::TestCase
  test "next verification date is derived from commission date" do
    equipment = Equipment.new(
      inventory_number: "INV-TEST-100",
      serial_number: "SN-TEST-100",
      model: "SMB100B",
      equipment_type: equipment_types(:generator),
      manufacturer: manufacturers(:rohde),
      department: departments(:svc),
      commissioned_on: Date.new(2026, 1, 10),
      verification_interval_months: 12
    )

    assert equipment.valid?
    assert_equal Date.new(2027, 1, 10), equipment.next_verification_on
  end

  test "overdue and due soon scopes" do
    assert_includes Equipment.overdue, equipment(:overdue_generator)
    assert_not_includes Equipment.overdue, equipment(:generator)
    assert_includes Equipment.due_soon(Date.new(2026, 12, 20)), equipment(:generator)
  end

  test "serial number is unique per manufacturer" do
    duplicate = equipment(:generator).dup
    duplicate.inventory_number = "INV-TEST-101"

    assert_not duplicate.valid?
    assert duplicate.errors[:serial_number].any?
  end

  test "verification interval must be positive" do
    equipment = equipment(:generator).dup
    equipment.inventory_number = "INV-TEST-102"
    equipment.serial_number = "SN-TEST-102"
    equipment.verification_interval_months = 0

    assert_not equipment.valid?
    assert equipment.errors[:verification_interval_months].any?
  end

  test "applying failed verification schedules retry in one month" do
    record = equipment(:generator)
    performed_on = Date.new(2026, 6, 1)

    record.apply_verification_result!(performed_on: performed_on, passed: false)

    assert_equal performed_on, record.last_verified_on
    assert_equal performed_on + 1.month, record.next_verification_on
  end
end