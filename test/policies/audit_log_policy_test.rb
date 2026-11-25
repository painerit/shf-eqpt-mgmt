require "test_helper"

class AuditLogPolicyTest < ActiveSupport::TestCase
  test "admin can read audit log" do
    policy = AuditLogPolicy.new(users(:admin), audit_logs(:created))

    assert policy.index?
    assert policy.show?
  end

  test "engineer cannot read audit log" do
    policy = AuditLogPolicy.new(users(:engineer), audit_logs(:created))

    assert_not policy.index?
    assert_not policy.show?
  end

  test "admin scope contains all records" do
    resolved = AuditLogPolicy::Scope.new(users(:admin), AuditLog.all).resolve

    assert_equal AuditLog.count, resolved.count
  end

  test "engineer scope is empty" do
    resolved = AuditLogPolicy::Scope.new(users(:engineer), AuditLog.all).resolve

    assert_empty resolved
  end
end