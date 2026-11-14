class Department < ApplicationRecord
  has_many :users, dependent: :restrict_with_error
  has_many :equipment,
           class_name: "Equipment",
           foreign_key: :department_id,
           inverse_of: :department,
           dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }
end