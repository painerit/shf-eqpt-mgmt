class VerificationSchedule < ApplicationRecord
  belongs_to :equipment
  belongs_to :normative_document, optional: true
  belongs_to :responsible_user, class_name: "User", optional: true

  has_many :verifications, dependent: :restrict_with_error
  has_many :audit_logs, as: :auditable, dependent: :destroy

  enum status: {
    planned: "planned",
    approved: "approved",
    completed: "completed",
    canceled: "canceled"
  }

  before_validation :set_period_year

  validates :planned_on, presence: true, uniqueness: { scope: :equipment_id }
  validates :period_year, presence: true, numericality: { only_integer: true, greater_than: 2000 }
  validate :period_year_matches_planned_on

  scope :upcoming, -> { where(planned_on: Date.current..) }
  scope :overdue, -> { where(planned_on: ...Date.current).where.not(status: :completed) }

  private

  def set_period_year
    self.period_year ||= planned_on&.year
  end

  def period_year_matches_planned_on
    return if planned_on.blank? || period_year.blank?
    return if planned_on.year == period_year

    errors.add(:period_year, "должен совпадать с годом плановой даты")
  end
end