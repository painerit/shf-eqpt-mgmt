require "test_helper"

class PublishVerificationJobTest < ActiveJob::TestCase
  test "publishes completed verification using fake client" do
    verification = verifications(:passed)

    PublishVerificationJob.perform_now(verification.id)

    verification.reload
    assert verification.external_id.start_with?("FAKE-")
    assert_equal "accepted", verification.external_status
    assert_nil verification.external_error
  end

  test "discards missing verification" do
    assert_nothing_raised do
      PublishVerificationJob.perform_now(999_999)
    end
  end
end