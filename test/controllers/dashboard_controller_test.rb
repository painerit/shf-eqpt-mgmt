require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects unauthenticated user to login" do
    get root_path

    assert_redirected_to login_path
  end

  test "renders dashboard for authenticated user" do
    sign_in_as users(:admin)

    get root_path

    assert_response :success
    assert_select "h1", "Панель управления"
    assert_select ".stat-card", minimum: 4
  end

  test "admin sees equipment from all departments" do
    sign_in_as users(:admin)

    get root_path

    assert_response :success
    assert_match "INV-TEST-003", response.body
  end

  test "customer does not see equipment from another department" do
    sign_in_as users(:customer)

    get root_path

    assert_response :success
    assert_no_match "INV-TEST-003", response.body
  end

  test "shows unread notifications" do
    sign_in_as users(:engineer)

    get root_path

    assert_response :success
    assert_select ".badge--warning", minimum: 1
  end
end