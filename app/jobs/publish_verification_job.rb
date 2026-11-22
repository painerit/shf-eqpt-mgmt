class PublishVerificationJob < ApplicationJob
  queue_as :default

  retry_on Integrations::RegistryClient::Error, wait: :polynomially_longer, attempts: 5
  discard_on ActiveRecord::RecordNotFound

  def perform(verification_id)
    verification = Verification.find(verification_id)
    Integrations::PublishVerification.new(verification).call
  end
end