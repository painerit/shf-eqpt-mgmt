require "test_helper"

class EquipmentQueryTest < ActiveSupport::TestCase
  test "searches by inventory number, serial number or model" do
    result = query(q: "SN-TEST-002")

    assert_includes result, equipment(:overdue_generator)
    assert_not_includes result, equipment(:generator)
  end

  test "escapes SQL LIKE wildcards in search query" do
    result = query(q: "%")

    assert_empty result
  end

  test "filters by equipment type" do
    result = query(equipment_type_id: equipment_types(:spectrum).id)

    assert_includes result, equipment(:decommissioned_generator)
    assert_not_includes result, equipment(:generator)
  end

  test "filters by department" do
    result = query(department_id: departments(:metrology).id)

    assert_includes result, equipment(:admin_generator)
    assert_not_includes result, equipment(:generator)
  end

  test "filters by status" do
    result = query(status: "decommissioned")

    assert_includes result, equipment(:decommissioned_generator)
    assert_not_includes result, equipment(:generator)
  end

  test "filters overdue equipment and excludes decommissioned" do
    result = query(due: "overdue")

    assert_includes result, equipment(:overdue_generator)
    assert_includes result, equipment(:admin_generator)
    assert_not_includes result, equipment(:generator)
    assert_not_includes result, equipment(:decommissioned_generator)
  end

  test "sorts by inventory number" do
    result = query(sort: "inventory_number_asc")

    assert_equal equipment(:generator), result.first
  end

  test "ignores unsupported sort option" do
    result = query(sort: "drop table equipment")

    assert_includes result, equipment(:generator)
  end

  private

  def query(params = {})
    EquipmentQuery.new(
      scope: Equipment.all,
      params: ActionController::Parameters.new(params)
    ).call
  end
end