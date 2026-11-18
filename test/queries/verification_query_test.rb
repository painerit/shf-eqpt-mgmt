require "test_helper"

class VerificationQueryTest < ActiveSupport::TestCase
  test "filters by status" do
    result = query(status: "passed")

    assert_includes result, verifications(:passed)
    assert_includes result, verifications(:admin_passed)
    assert_not_includes result, verifications(:draft)
  end

  test "filters by department through equipment" do
    result = query(department_id: departments(:svc).id)

    assert_includes result, verifications(:passed)
    assert_includes result, verifications(:failed)
    assert_includes result, verifications(:draft)
    assert_not_includes result, verifications(:admin_passed)
  end

  test "searches by equipment serial number" do
    result = query(q: "SN-TEST-002")

    assert_includes result, verifications(:failed)
    assert_not_includes result, verifications(:passed)
  end

  test "filters by performed date range" do
    result = query(date_from: "2026-11-01", date_to: "2026-11-30")

    assert_includes result, verifications(:draft)
    assert_not_includes result, verifications(:passed)
  end

  test "ignores unsupported status" do
    result = query(status: "unknown")

    assert_includes result, verifications(:passed)
  end

  private

  def query(params = {})
    VerificationQuery.new(
      scope: Verification.all,
      params: ActionController::Parameters.new(params)
    ).call
  end
end