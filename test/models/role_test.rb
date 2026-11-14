require "test_helper"

class RoleTest < ActiveSupport::TestCase
  test "code must be unique" do
    role = Role.new(code: "admin", name: "Дубликат")

    assert_not role.valid?
    assert role.errors[:code].any?
  end

  test "role predicates reflect code" do
    assert roles(:admin).admin?
    assert roles(:metrologist).metrologist?
    assert roles(:engineer).engineer?
    assert roles(:customer).customer?
  end
end