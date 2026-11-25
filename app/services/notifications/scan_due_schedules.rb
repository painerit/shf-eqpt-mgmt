module Notifications
  class ScanDueSchedules
    Result = Struct.new(:created, :skipped, keyword_init: true)

    def initialize(scope: Equipment.all)
      @scope = scope
    end

    def call
      created = 0
      skipped = 0
      metrologists = active_metrologists

      overdue_scope.find_each do |equipment|
        result = notify(equipment, "overdue", metrologists)
        created += result[:created]
        skipped += result[:skipped]
      end

      due_soon_scope.find_each do |equipment|
        result = notify(equipment, "due_soon", metrologists)
        created += result[:created]
        skipped += result[:skipped]
      end

      Result.new(created: created, skipped: skipped)
    end

    private

    attr_reader :scope

    def overdue_scope
      scope.includes(:responsible_user).overdue
    end

    def due_soon_scope
      scope.includes(:responsible_user).due_soon
    end

    def active_metrologists
      User.active.joins(:role).where(roles: { code: "metrologist" }).to_a
    end

    def notify(equipment, kind, metrologists)
      created = 0
      skipped = 0

      recipients_for(equipment, metrologists).each do |user|
        begin
          notification = Notification.find_or_create_by!(
            user: user,
            notifiable: equipment,
            kind: kind,
            due_on: equipment.next_verification_on
          ) do |record|
            record.message = message_for(equipment, kind)
          end

          notification.previously_new_record? ? created += 1 : skipped += 1
        rescue ActiveRecord::RecordNotUnique
          skipped += 1
        end
      end

      { created: created, skipped: skipped }
    end

    def recipients_for(equipment, metrologists)
      ([equipment.responsible_user] + metrologists)
        .compact
        .select(&:active?)
        .uniq
    end

    def message_for(equipment, kind)
      prefix = kind == "overdue" ? "Просрочена поверка" : "Приближается срок поверки"
      due_on = equipment.next_verification_on&.strftime("%d.%m.%Y")

      "#{prefix} оборудования #{equipment.inventory_number} (#{equipment.model}) до #{due_on}"
    end
  end
end