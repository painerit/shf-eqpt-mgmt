class Manufacturer < ApplicationRecord
  has_many :equipment,
           class_name: "Equipment",
           foreign_key: :manufacturer_id,
           inverse_of: :manufacturer,
           dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true
end