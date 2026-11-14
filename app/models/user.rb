class User < ApplicationRecord
  has_secure_password

  belongs_to :role
  belongs_to :department, optional: true

  has_many :responsible_equipment,
           class_name: "Equipment",
           foreign_key: :responsible_user_id,
           inverse_of: :responsible_user,
           dependent: :nullify
  has_many :verification_schedules,
           foreign_key: :responsible_user_id,
           inverse_of: :responsible_user,
           dependent: :nullify
  has_many :verifications,
           foreign_key: :performed_by_id,
           inverse_of: :performed_by,
           dependent: :nullify
  has_many :audit_logs, dependent: :nullify
  has_many :notifications, dependent: :destroy

  before_validation :normalize_email

  validates :email,
            presence: true,
            format: { with: URI::MailTo::EMAIL_REGEXP },
            uniqueness: { case_sensitive: false }
  validates :full_name, presence: true
  validates :password, length: { minimum: 8 }, allow_nil: true

  scope :active, -> { where(active: true) }

  def self.authenticate(email, password)
    active.find_by(email: email.to_s.strip.downcase)&.authenticate(password)
  end

  def admin?
    role&.admin?
  end

  def metrologist?
    role&.metrologist?
  end

  def engineer?
    role&.engineer?
  end

  def customer?
    role&.customer?
  end

  def display_name
    full_name.presence || email
  end

  private

  def normalize_email
    self.email = email.to_s.strip.downcase
  end
end