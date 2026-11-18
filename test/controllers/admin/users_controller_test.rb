require "test_helper"

class Admin::UsersControllerTest < ActionDispatch::IntegrationTest
  test "admin sees users list" do
    sign_in_as users(:admin)

    get admin_users_path

    assert_response :success
    assert_select "h1", "Пользователи"
    assert_match users(:engineer).email, response.body
  end

  test "engineer cannot access users list" do
    sign_in_as users(:engineer)

    get admin_users_path

    assert_redirected_to root_path
    assert_equal "Недостаточно прав для выполнения этого действия.", flash[:alert]
  end

  test "admin creates a user" do
    sign_in_as users(:admin)

    assert_difference("User.count", 1) do
      post admin_users_path, params: {
        user: {
          full_name: "Новый Инженер",
          email: "new.engineer@example.com",
          role_id: roles(:engineer).id,
          department_id: departments(:svc).id,
          password: "password123",
          password_confirmation: "password123",
          active: "1"
        }
      }
    end

    created = User.find_by!(email: "new.engineer@example.com")
    assert_equal roles(:engineer), created.role
    assert_redirected_to admin_users_path
  end

  test "admin updates user role and department" do
    sign_in_as users(:admin)

    patch admin_user_path(users(:engineer)), params: {
      user: {
        full_name: "Петров Алексей Петрович",
        role_id: roles(:metrologist).id,
        department_id: departments(:metrology).id,
        active: "1"
      }
    }

    assert_redirected_to admin_users_path
    user = users(:engineer).reload
    assert_equal "Петров Алексей Петрович", user.full_name
    assert_equal roles(:metrologist), user.role
    assert_equal departments(:metrology), user.department
  end

  test "admin can open new user form" do
    sign_in_as users(:admin)

    get new_admin_user_path

    assert_response :success
    assert_select "h1", "Новый пользователь"
  end
end