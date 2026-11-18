class EquipmentQuery
  SORTS = {
    "next_verification_on_asc" => ["next_verification_on", "asc"],
    "inventory_number_asc" => ["inventory_number", "asc"],
    "model_asc" => ["model", "asc"],
    "created_at_desc" => ["created_at", "desc"]
  }.freeze

  def initialize(scope:, params:)
    @scope = scope
    @params = params
  end

  def call
    relation = scope.includes(:equipment_type, :manufacturer, :department, :responsible_user)
    relation = search(relation)
    relation = filter_reference(relation, :equipment_type_id, params[:equipment_type_id])
    relation = filter_reference(relation, :manufacturer_id, params[:manufacturer_id])
    relation = filter_reference(relation, :department_id, params[:department_id])
    relation = filter_status(relation)
    relation = filter_due(relation)
    sort(relation)
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

  def filter_reference(relation, column, value)
    return relation if value.blank?

    id = value.to_i
    return relation unless id.positive?

    relation.where(column => id)
  end

  def filter_status(relation)
    status = params[:status].to_s
    return relation unless Equipment.statuses.key?(status)

    relation.where(status: status)
  end

  def filter_due(relation)
    case params[:due].to_s
    when "overdue"
      relation.overdue
    when "due_soon"
      relation.due_soon
    when "no_date"
      relation.where(next_verification_on: nil)
    else
      relation
    end
  end

  def sort(relation)
    column, direction = SORTS.fetch(params[:sort].to_s, SORTS["next_verification_on_asc"])
    relation.order(Arel.sql("#{column} #{direction}"))
  end
end