class AuditLog < ApplicationRecord
  belongs_to :user, optional: true
  belongs_to :auditable, polymorphic: true

  validates :action, presence: true

  scope :recent, -> { order(created_at: :desc) }

  def self.record!(auditable:, user: nil, action:, audited_changes: {}, ip_address: nil, user_agent: nil)
    create!(
      auditable: auditable,
      user: user,
      action: action,
      audited_changes: audited_changes.presence || {},
      ip_address: ip_address,
      user_agent: user_agent
    )
  end

  def changed_fields
    audited_changes.keys
  end
end