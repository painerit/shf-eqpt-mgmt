require "test_helper"

class EquipmentPolicyTest < ActiveSupport::TestCase
  test "admin and metrologist can create and update equipment" do
    assert EquipmentPolicy.new(users(:admin), equipment(:generator)).create?
    assert EquipmentPolicy.new(users(:admin), equipment(:generator)).update?
    assert EquipmentPolicy.new(users(:metrologist), equipment(:generator)).create?
    assert EquipmentPolicy.new(users(:metrologist), equipment(:generator)).update?
  end

  test "engineer can read own department equipment but cannot manage it" do
    policy = EquipmentPolicy.new(users(:engineer), equipment(:generator))

    assert policy.show?
    assert_not policy.create?
    assert_not policy.update?
  end

  test "engineer cannot read equipment from another department" do
    policy = EquipmentPolicy.new(users(:engineer), equipment(:admin_generator))

    assert_not policy.show?
  end

  test "customer can read only in-service equipment of own department" do
    assert EquipmentPolicy.new(users(:customer), equipment(:generator)).show?
    assert_not EquipmentPolicy.new(users(:customer), equipment(:decommissioned_generator)).show?
    assert_not EquipmentPolicy.new(users(:customer), equipment(:admin_generator)).show?
  end

  test "admin scope contains all equipment" do
    resolved = EquipmentPolicy::Scope.new(users(:admin), Equipment.all).resolve

    assert_equal Equipment.count, resolved.count
  end

  test "engineer scope is limited to own department" do
    resolved = EquipmentPolicy::Scope.new(users(:engineer), Equipment.all).resolve

    assert_includes resolved, equipment(:generator)
    assert_includes resolved, equipment(:decommissioned_generator)
    assert_not_includes resolved, equipment(:admin_generator)
  end

  test "customer scope contains only in-service equipment of own department" do
    resolved = EquipmentPolicy::Scope.new(users(:customer), Equipment.all).resolve

    assert_includes resolved, equipment(:generator)
    assert_not_includes resolved, equipment(:decommissioned_generator)
    assert_not_includes resolved, equipment(:admin_generator)
  end
end