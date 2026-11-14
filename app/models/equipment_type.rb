class EquipmentType < ApplicationRecord
  has_many :equipment,
           class_name: "Equipment",
           foreign_key: :equipment_type_id,
           inverse_of: :equipment_type,
           dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  scope :active, -> { where(active: true) }
end