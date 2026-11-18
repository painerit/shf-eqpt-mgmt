module Schedules
  class GenerateYear
    Result = Struct.new(:created, :skipped, keyword_init: true)

    def initialize(year:, department_id: nil)
      @year = year.to_i
      @department_id = department_id.presence
    end

    def call
      raise ArgumentError, "Некорректный год" if year <= 2000

      created = 0
      skipped = 0

      ActiveRecord::Base.transaction do
        equipment_scope.find_each do |equipment|
          schedule = VerificationSchedule.find_or_create_by!(
            equipment: equipment,
            planned_on: equipment.next_verification_on
          ) do |record|
            record.period_year = year
            record.responsible_user = equipment.responsible_user
            record.status = "planned"
            record.notes = "Сформировано автоматически"
          end

          schedule.previously_new_record? ? created += 1 : skipped += 1
        end
      end

      Result.new(created: created, skipped: skipped)
    end

    private

    attr_reader :year, :department_id

    def equipment_scope
      scope = Equipment
              .where.not(status: :decommissioned)
              .where(next_verification_on: Date.new(year, 1, 1)..Date.new(year, 12, 31))

      department_id ? scope.where(department_id: department_id) : scope
    end
  end
end