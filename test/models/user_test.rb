require "test_helper"

class UserTest < ActiveSupport::TestCase
  test "email is normalized before validation" do
    user = User.new(
      email: "  NEW.USER@Example.COM ",
      full_name: "Новый Пользователь",
      role: roles(:engineer),
      password: "password123",
      password_confirmation: "password123"
    )

    assert user.valid?
    assert_equal "new.user@example.com", user.email
  end

  test "authenticate returns user for valid password" do
    assert users(:engineer).authenticate("password123")
    assert_not users(:engineer).authenticate("wrong-password")
  end

  test "inactive user cannot authenticate" do
    users(:engineer).update!(active: false)

    assert_nil User.authenticate("engineer@example.com", "password123")
  end

  test "role predicates reflect assigned role" do
    assert users(:admin).admin?
    assert users(:engineer).engineer?
    assert users(:customer).customer?
    assert_not users(:engineer).admin?
  end
end