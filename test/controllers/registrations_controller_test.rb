require "test_helper"

class RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "renders registration page" do
    get signup_path

    assert_response :success
    assert_select "h1", "Регистрация заказчика"
  end

  test "registers a customer" do
    assert_difference("User.count", 1) do
      post signup_path, params: {
        user: {
          full_name: "Новый Заказчик",
          email: "new.customer@example.com",
          phone: "+7 999 000-00-00",
          department_id: departments(:svc).id,
          password: "password123",
          password_confirmation: "password123"
        }
      }
    end

    user = User.find_by!(email: "new.customer@example.com")
    assert_equal "customer", user.role.code
    assert user.active?
    assert_redirected_to root_path
  end

  test "does not allow role escalation during registration" do
    post signup_path, params: {
      user: {
        full_name: "Новый Заказчик",
        email: "role.escalation@example.com",
        role_id: roles(:admin).id,
        password: "password123",
        password_confirmation: "password123"
      }
    }

    assert_equal "customer", User.find_by!(email: "role.escalation@example.com").role.code
  end

  test "rejects password mismatch" do
    assert_no_difference("User.count") do
      post signup_path, params: {
        user: {
          full_name: "Новый Заказчик",
          email: "bad.password@example.com",
          password: "password123",
          password_confirmation: "different-password"
        }
      }
    end

    assert_response :unprocessable_entity
    assert_select ".form-errors"
  end
end