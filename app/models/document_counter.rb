class DocumentCounter < ApplicationRecord
  validates :kind, presence: true
  validates :year, presence: true, numericality: { only_integer: true, greater_than: 2000 }
  validates :value, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :year, uniqueness: { scope: :kind }

  def self.next_value!(kind:, year: Date.current.year)
    transaction do
      counter = lock.find_by(kind: kind, year: year)

      if counter
        counter.update!(value: counter.value + 1)
      else
        counter = create!(kind: kind, year: year, value: 1)
      end

      counter.value
    end
  rescue ActiveRecord::RecordNotUnique
    retry
  end
end