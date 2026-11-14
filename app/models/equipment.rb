class Equipment < ApplicationRecord
  belongs_to :equipment_type
  belongs_to :manufacturer
  belongs_to :department
  belongs_to :responsible_user, class_name: "User", optional: true, inverse_of: :responsible_equipment

  has_many :verification_schedules,
           foreign_key: :equipment_id,
           inverse_of: :equipment,
           dependent: :restrict_with_error
  has_many :verifications,
           foreign_key: :equipment_id,
           inverse_of: :equipment,
           dependent: :restrict_with_error
  has_many :notifications, as: :notifiable, dependent: :destroy

  enum status: {
    in_service: "in_service",
    in_repair: "in_repair",
    decommissioned: "decommissioned",
    reserved: "reserved"
  }

  before_validation :set_next_verification_on, on: :create

  validates :inventory_number, presence: true, uniqueness: true
  validates :serial_number, presence: true, uniqueness: { scope: :manufacturer_id }
  validates :model, presence: true
  validates :verification_interval_months,
            numericality: { only_integer: true, greater_than: 0 }
  validate :next_verification_after_last

  scope :due_soon, ->(date = Date.current) { where(next_verification_on: date..date + 30.days) }
  scope :overdue, ->(date = Date.current) { where(next_verification_on: ...date) }

  def overdue?
    next_verification_on.present? && next_verification_on < Date.current
  end

  def due_soon?
    next_verification_on.present? && !overdue? && next_verification_on <= Date.current + 30.days
  end

  def next_verification_in_days
    return if next_verification_on.blank?

    (next_verification_on - Date.current).to_i
  end

  def apply_verification_result!(performed_on:, passed:)
    interval = if passed
                 verification_interval_months.months
               else
                 1.month
               end

    update!(
      last_verified_on: performed_on,
      next_verification_on: performed_on + interval
    )
  end

  private

  def set_next_verification_on
    return if next_verification_on.present?

    base_date = commissioned_on || Date.current
    self.next_verification_on = base_date + verification_interval_months.to_i.months
  end

  def next_verification_after_last
    return if last_verified_on.blank? || next_verification_on.blank?
    return if next_verification_on >= last_verified_on

    errors.add(:next_verification_on, "должна быть позже даты последней поверки")
  end
end