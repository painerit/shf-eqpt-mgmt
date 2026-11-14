class NormativeDocument < ApplicationRecord
  has_many :verification_schedules, dependent: :restrict_with_error

  validates :doc_number, presence: true, uniqueness: true
  validates :title, presence: true

  scope :actual, -> { where("valid_until IS NULL OR valid_until >= ?", Date.current) }
end