require "test_helper"

class Notifications::ScanDueSchedulesTest < ActiveSupport::TestCase
  setup do
    Notification.delete_all
    @due_soon_equipment = Equipment.create!(
      inventory_number: "INV-DUE-001",
      serial_number: "SN-DUE-001",
      model: "SMB100B",
      equipment_type: equipment_types(:generator),
      manufacturer: manufacturers(:keysight),
      department: departments(:svc),
      responsible_user: users(:engineer),
      status: "in_service",
      commissioned_on: Date.current - 1.year,
      verification_interval_months: 12,
      last_verified_on: Date.current - 1.year,
      next_verification_on: Date.current + 10.days
    )
  end

  test "creates notifications for overdue and due soon equipment" do
    scope = Equipment.where(id: [equipment(:overdue_generator).id, @due_soon_equipment.id])

    result = Notifications::ScanDueSchedules.new(scope: scope).call

    assert_equal 4, result.created
    assert_equal 0, result.skipped
    assert Notification.exists?(
      user: users(:engineer),
      notifiable: equipment(:overdue_generator),
      kind: "overdue"
    )
    assert Notification.exists?(
      user: users(:metrologist),
      notifiable: @due_soon_equipment,
      kind: "due_soon"
    )
  end

  test "does not duplicate existing notifications" do
    scope = Equipment.where(id: [equipment(:overdue_generator).id, @due_soon_equipment.id])
    Notifications::ScanDueSchedules.new(scope: scope).call

    result = Notifications::ScanDueSchedules.new(scope: scope).call

    assert_equal 0, result.created
    assert_equal 4, result.skipped
  end

  test "ignores decommissioned equipment" do
    scope = Equipment.where(id: [equipment(:decommissioned_generator).id, @due_soon_equipment.id])

    Notifications::ScanDueSchedules.new(scope: scope).call

    assert_not Notification.exists?(
      notifiable: equipment(:decommissioned_generator)
    )
  end
end