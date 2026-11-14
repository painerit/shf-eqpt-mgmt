class Verification < ApplicationRecord
  belongs_to :verification_schedule, optional: true
  belongs_to :equipment
  belongs_to :performed_by, class_name: "User", optional: true, inverse_of: :verifications

  has_many :verification_results,
           foreign_key: :verification_id,
           inverse_of: :verification,
           dependent: :destroy

  accepts_nested_attributes_for :verification_results,
                                allow_destroy: true,
                                reject_if: :all_blank

  enum status: {
    planned: "planned",
    in_progress: "in_progress",
    passed: "passed",
    failed: "failed",
    canceled: "canceled"
  }

  validates :equipment, presence: true
  validates :certificate_number, presence: true, if: :passed?
  validates :protocol_number, presence: true, if: :completed?
  validate :schedule_belongs_to_equipment
  validate :certificate_only_for_passed
  validate :completed_verification_has_date

  scope :completed, -> { where(status: %w[passed failed]) }
  scope :this_month, -> { where(performed_on: Date.current.all_month) }

  def completed?
    passed? || failed?
  end

  def publishable?
    completed? && external_id.blank?
  end

  private

  def schedule_belongs_to_equipment
    return if verification_schedule.blank? || equipment.blank?
    return if verification_schedule.equipment_id == equipment_id

    errors.add(:verification_schedule, "относится к другому оборудованию")
  end

  def certificate_only_for_passed
    return if certificate_number.blank? || passed?

    errors.add(:certificate_number, "может быть выдан только при положительном результате")
  end

  def completed_verification_has_date
    return if !completed? || performed_on.present?

    errors.add(:performed_on, "должна быть заполнена для завершённой поверки")
  end
end