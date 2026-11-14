class VerificationResult < ApplicationRecord
  belongs_to :verification

  validates :parameter_name, presence: true
  validates :measured_value, numericality: true, allow_nil: true
  validates :passed, inclusion: { in: [true, false] }

  scope :failed, -> { where(passed: false) }
end