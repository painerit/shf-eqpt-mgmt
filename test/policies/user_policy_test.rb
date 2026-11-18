require "test_helper"

class UserPolicyTest < ActiveSupport::TestCase
  test "admin can manage users" do
    policy = UserPolicy.new(users(:admin), users(:engineer))

    assert policy.index?
    assert policy.create?
    assert policy.update?
  end

  test "engineer cannot manage users" do
    policy = UserPolicy.new(users(:engineer), users(:engineer))

    assert_not policy.index?
    assert_not policy.create?
    assert_not policy.update?
  end

  test "non-admin scope contains only current user" do
    resolved = UserPolicy::Scope.new(users(:engineer), User.all).resolve

    assert_equal [users(:engineer)], resolved.to_a
  end

  test "admin scope contains all users" do
    resolved = UserPolicy::Scope.new(users(:admin), User.all).resolve

    assert_equal User.count, resolved.count
  end
end