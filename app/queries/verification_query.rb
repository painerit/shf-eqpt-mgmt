class VerificationQuery
  def initialize(scope:, params:)
    @scope = scope
    @params = params
  end

  def call
    relation = scope
               .includes(:equipment, :performed_by, :verification_schedule)
    relation = relation.left_joins(:equipment) unless relation.joins_values.include?(:equipment)

    relation = search(relation)
    relation = filter_department(relation)
    relation = filter_status(relation)
    relation = filter_dates(relation)
    relation.order(Arel.sql("verifications.performed_on DESC NULLS LAST, verifications.created_at DESC"))
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

  def filter_status(relation)
    status = params[:status].to_s
    return relation unless Verification.statuses.key?(status)

    relation.where(status: status)
  end

  def filter_dates(relation)
    relation = relation.where("performed_on >= ?", params[:date_from]) if params[:date_from].present?
    relation = relation.where("performed_on <= ?", params[:date_to]) if params[:date_to].present?
    relation
  end
end