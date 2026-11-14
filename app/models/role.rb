class Role < ApplicationRecord
  has_many :users, dependent: :restrict_with_error

  validates :code, presence: true, uniqueness: true
  validates :name, presence: true

  def admin?
    code == "admin"
  end

  def metrologist?
    code == "metrologist"
  end

  def engineer?
    code == "engineer"
  end

  def customer?
    code == "customer"
  end
end