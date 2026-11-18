require "test_helper"

class EquipmentControllerTest < ActionDispatch::IntegrationTest
  test "requires authentication" do
    get equipment_index_path

    assert_redirected_to login_path
  end

  test "admin sees equipment from all departments" do
    sign_in_as users(:admin)

    get equipment_index_path

    assert_response :success
    assert_match "INV-TEST-001", response.body
    assert_match "INV-TEST-003", response.body
  end

  test "engineer sees only own department equipment" do
    sign_in_as users(:engineer)

    get equipment_index_path

    assert_response :success
    assert_match "INV-TEST-001", response.body
    assert_no_match "INV-TEST-003", response.body
  end

  test "customer sees only in-service equipment of own department" do
    sign_in_as users(:customer)

    get equipment_index_path

    assert_response :success
    assert_match "INV-TEST-001", response.body
    assert_no_match "INV-TEST-003", response.body
    assert_no_match "INV-TEST-004", response.body
  end

  test "searches equipment by serial number" do
    sign_in_as users(:admin)

    get equipment_index_path, params: { q: "SN-TEST-002" }

    assert_response :success
    assert_match "INV-TEST-002", response.body
    assert_no_match "INV-TEST-001", response.body
  end

  test "filters overdue equipment" do
    sign_in_as users(:admin)

    get equipment_index_path, params: { due: "overdue" }

    assert_response :success
    assert_match "INV-TEST-002", response.body
    assert_no_match "INV-TEST-001", response.body
  end

  test "admin creates equipment and writes audit log" do
    sign_in_as users(:admin)

    assert_difference("Equipment.count", 1) do
      assert_difference("AuditLog.where(action: 'create').count", 1) do
        post equipment_index_path, params: {
          equipment: {
            inventory_number: "INV-NEW-001",
            serial_number: "SN-NEW-001",
            model: "SMB100B",
            equipment_type_id: equipment_types(:generator).id,
            manufacturer_id: manufacturers(:keysight).id,
            department_id: departments(:svc).id,
            responsible_user_id: users(:engineer).id,
            status: "in_service",
            commissioned_on: "2026-01-01",
            verification_interval_months: 12,
            location: "Лаборатория 4"
          }
        }
      end
    end

    created = Equipment.find_by!(inventory_number: "INV-NEW-001")
    assert_redirected_to equipment_path(created)
    assert_equal "create", AuditLog.where(auditable: created).last.action
  end

  test "engineer cannot create equipment" do
    sign_in_as users(:engineer)

    assert_no_difference("Equipment.count") do
      post equipment_index_path, params: {
        equipment: {
          inventory_number: "INV-DENIED-001",
          serial_number: "SN-DENIED-001",
          model: "SMB100B",
          equipment_type_id: equipment_types(:generator).id,
          manufacturer_id: manufacturers(:keysight).id,
          department_id: departments(:svc).id,
          status: "in_service",
          verification_interval_months: 12
        }
      }
    end

    assert_redirected_to root_path
    assert_equal "Недостаточно прав для выполнения этого действия.", flash[:alert]
  end

  test "admin updates equipment and writes audit log" do
    sign_in_as users(:admin)
    record = equipment(:generator)
    before_count = AuditLog.where(action: "update").count

    patch equipment_path(record), params: { equipment: { location: "Новая лаборатория" } }

    assert_redirected_to equipment_path(record)
    assert_equal "Новая лаборатория", record.reload.location
    assert_equal before_count + 1, AuditLog.where(action: "update").count
  end

  test "engineer cannot edit equipment" do
    sign_in_as users(:engineer)

    get edit_equipment_path(equipment(:generator))

    assert_redirected_to root_path
  end

  test "customer cannot see equipment from another department" do
    sign_in_as users(:customer)

    get equipment_path(equipment(:admin_generator))

    assert_redirected_to root_path
    assert_equal "Недостаточно прав для выполнения этого действия.", flash[:alert]
  end

  test "customer does not see internal audit history" do
    sign_in_as users(:customer)

    get equipment_path(equipment(:generator))

    assert_response :success
    assert_no_match "История изменений", response.body
  end

  test "show page displays equipment details and history" do
    sign_in_as users(:admin)

    get equipment_path(equipment(:generator))

    assert_response :success
    assert_select "h1", "INV-TEST-001"
    assert_match "История поверок", response.body
    assert_match "История изменений", response.body
  end

  test "admin can open new equipment form" do
    sign_in_as users(:admin)

    get new_equipment_path

    assert_response :success
    assert_select "h1", "Новый прибор"
  end
end