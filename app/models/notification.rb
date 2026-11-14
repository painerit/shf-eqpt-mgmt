class Notification < ApplicationRecord
  belongs_to :user
  belongs_to :notifiable, polymorphic: true

  validates :kind, presence: true
  validates :message, presence: true
  validates :kind,
            uniqueness: {
              scope: [:user_id, :notifiable_type, :notifiable_id, :due_on]
            }

  scope :unread, -> { where(read_at: nil) }
  scope :recent, -> { order(created_at: :desc) }

  def read?
    read_at.present?
  end

  def mark_as_read!
    update!(read_at: Time.current)
  end
end