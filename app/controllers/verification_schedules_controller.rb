class VerificationSchedulesController < ApplicationController
  before_action :set_schedule, only: [:show, :edit, :update, :approve]
  before_action :load_form_collections, only: [:new, :create, :edit, :update]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    authorize VerificationSchedule

    @query = VerificationScheduleQuery.new(
      scope: policy_scope(VerificationSchedule),
      params: params
    )
    @schedules = @query.call.page(params[:page]).per(20)
    load_filter_collections
  end

  def show
    authorize @schedule

    @verifications = @schedule.verifications
                              .includes(:performed_by)
                              .order(performed_on: :desc, created_at: :desc)
    @audit_logs = @schedule.audit_logs.includes(:user).recent.limit(10)
  end

  def new
    @schedule = VerificationSchedule.new(
      equipment: Equipment.find_by(id: params[:equipment_id]),
      planned_on: Date.current,
      status: "planned"
    )
    authorize @schedule
  end

  def create
    @schedule = VerificationSchedule.new(schedule_params)
    authorize @schedule

    if @schedule.save
      record_audit("create", @schedule.saved_changes)
      redirect_to verification_schedule_path(@schedule), notice: "Пункт графика создан."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @schedule
  end

  def update
    authorize @schedule

    if @schedule.update(schedule_params)
      record_audit("update", @schedule.saved_changes)
      redirect_to verification_schedule_path(@schedule), notice: "Пункт графика обновлён."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def approve
    authorize @schedule, :approve?

    @schedule.update!(status: "approved")
    record_audit("approve", @schedule.saved_changes)

    redirect_to verification_schedule_path(@schedule), notice: "График согласован."
  end

  def generate
    authorize VerificationSchedule, :generate?

    result = Schedules::GenerateYear.new(
      year: params[:period_year],
      department_id: params[:department_id]
    ).call

    redirect_to verification_schedules_path,
                notice: "График сформирован: создано #{result.created}, уже было #{result.skipped}."
  rescue ArgumentError
    redirect_to verification_schedules_path, alert: "Укажите корректный год формирования графика."
  end

  private

  def set_schedule
    @schedule = VerificationSchedule.find(params[:id])
  end

  def load_filter_collections
    @departments = Department.active.order(:name)
    @schedule_statuses = VerificationSchedule.statuses.keys
    @years = (Date.current.year - 1)..(Date.current.year + 2)
  end

  def load_form_collections
    @equipment = Equipment.where.not(status: :decommissioned).order(:inventory_number)
    @normative_documents = NormativeDocument.actual.order(:doc_number)
    @responsible_users = User.active.order(:full_name)
  end

  def schedule_params
    attributes = params.require(:verification_schedule).permit(
      :equipment_id,
      :normative_document_id,
      :responsible_user_id,
      :planned_on,
      :status,
      :notes
    )

    if attributes[:status].present? && !VerificationSchedule.statuses.key?(attributes[:status])
      attributes[:status] = "planned"
    end

    attributes
  end

  def record_audit(action, changes)
    return if changes.blank?

    AuditLog.record!(
      auditable: @schedule,
      user: current_user,
      action: action,
      audited_changes: changes,
      ip_address: Current.request_ip,
      user_agent: Current.user_agent
    )
  end
end