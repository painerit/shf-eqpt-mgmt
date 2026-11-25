class AuditLogQuery
  def initialize(scope:, params:)
    @scope = scope
    @params = params
  end

  def call
    relation = scope.includes(:user, :auditable).recent

    relation = filter_user(relation)
    relation = filter_action(relation)
    relation = filter_auditable_type(relation)
    filter_dates(relation)
  end

  private

  attr_reader :scope, :params

  def filter_user(relation)
    user_id = params[:user_id].to_i
    return relation unless user_id.positive?

    relation.where(user_id: user_id)
  end

  def filter_action(relation)
    action = params[:event].to_s
    return relation if action.blank?

    relation.where(action: action)
  end

  def filter_auditable_type(relation)
    type = params[:auditable_type].to_s
    return relation if type.blank?

    relation.where(auditable_type: type)
  end

  def filter_dates(relation)
    date_from = parse_date(params[:date_from])
    date_to = parse_date(params[:date_to])

    relation = relation.where("created_at >= ?", date_from.beginning_of_day) if date_from
    relation = relation.where("created_at <= ?", date_to.end_of_day) if date_to
    relation
  end

  def parse_date(value)
    return if value.blank?

    Date.parse(value.to_s)
  rescue ArgumentError
    nil
  end
end