class VerificationScheduleQuery
  def initialize(scope:, params:)
    @scope = scope
    @params = params
  end

  def call
    relation = scope
               .includes(:equipment, :responsible_user, :normative_document)
               .left_joins(:equipment)

    relation = search(relation)
    relation = filter_department(relation)
    relation = filter_year(relation)
    relation = filter_status(relation)
    relation.order(:planned_on)
  end

  private

  attr_reader :scope, :params

  def search(relation)
    query = params[:q].to_s.strip
    return relation if query.blank?

    pattern = "%#{ActiveRecord::Base.sanitize_sql_like(query)}%"
    relation.where(
      "equipment.inventory_number ILIKE :query OR " \
      "equipment.serial_number ILIKE :query OR " \
      "equipment.model ILIKE :query",
      query: pattern
    )
  end

  def filter_department(relation)
    department_id = params[:department_id].to_i
    return relation unless department_id.positive?

    relation.where(equipment: { department_id: department_id })
  end

  def filter_year(relation)
    year = params[:period_year].to_i
    return relation unless year.positive?

    relation.where(period_year: year)
  end

  def filter_status(relation)
    status = params[:status].to_s
    return relation unless VerificationSchedule.statuses.key?(status)

    relation.where(status: status)
  end
end