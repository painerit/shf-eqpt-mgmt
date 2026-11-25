require "test_helper"

class Admin::AuditLogsControllerTest < ActionDispatch::IntegrationTest
  test "admin sees audit log" do
    sign_in_as users(:admin)

    get admin_audit_logs_path

    assert_response :success
    assert_select "h1", "Журнал аудита"
    assert_match audit_logs(:created).action, response.body
  end

  test "engineer cannot access audit log" do
    sign_in_as users(:engineer)

    get admin_audit_logs_path

    assert_redirected_to root_path
  end

  test "admin opens audit record" do
    sign_in_as users(:admin)

    get admin_audit_log_path(audit_logs(:created))

    assert_response :success
    assert_select "h1", "Запись аудита"
    assert_match "Изменения", response.body
  end

  test "admin filters audit log by action" do
    sign_in_as users(:admin)

    get admin_audit_logs_path, params: { event: "create" }

    assert_response :success
    assert_select "td", text: "Создание"
    assert_select "td", text: "Изменение", count: 0
  end
end