class EquipmentController < ApplicationController
  before_action :set_equipment, only: [:show, :edit, :update]
  before_action :load_form_collections, only: [:new, :create, :edit, :update]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Equipment

    @query = EquipmentQuery.new(scope: policy_scope(Equipment), params: params)
    @equipment = @query.call.page(params[:page]).per(20)
    load_filter_collections
  end

  def show
    authorize @equipment

    @verifications = @equipment.verifications
                              .includes(:performed_by, :verification_results)
                              .order(performed_on: :desc, created_at: :desc)
                              .limit(10)
    @schedules = @equipment.verification_schedules
                          .includes(:responsible_user, :normative_document)
                          .order(:planned_on)
                          .limit(10)
    @audit_logs = if current_user.customer?
                    AuditLog.none
                  else
                    @equipment.audit_logs.includes(:user).recent.limit(10)
                  end
  end

  def new
    @equipment = Equipment.new(
      status: "in_service",
      verification_interval_months: 12,
      department: current_user.department
    )
    authorize @equipment
  end

  def create
    @equipment = Equipment.new(equipment_params)
    authorize @equipment

    if @equipment.save
      record_audit("create", @equipment.saved_changes)
      redirect_to equipment_path(@equipment), notice: "Прибор добавлен в реестр."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @equipment
  end

  def update
    authorize @equipment

    if @equipment.update(equipment_params)
      record_audit("update", @equipment.saved_changes)
      redirect_to equipment_path(@equipment), notice: "Данные прибора обновлены."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_equipment
    @equipment = Equipment.find(params[:id])
  end

  def load_filter_collections
    @equipment_types = EquipmentType.active.order(:name)
    @manufacturers = Manufacturer.order(:name)
    @departments = Department.active.order(:name)
  end

  def load_form_collections
    @equipment_types = EquipmentType.active.order(:name)
    @manufacturers = Manufacturer.order(:name)
    @departments = Department.active.order(:name)
    @responsible_users = User.active.order(:full_name)
  end

  def record_audit(action, changes)
    return if changes.blank?

    AuditLog.record!(
      auditable: @equipment,
      user: current_user,
      action: action,
      audited_changes: changes,
      ip_address: Current.request_ip,
      user_agent: Current.user_agent
    )
  end

  def equipment_params
    params.require(:equipment).permit(
      :inventory_number,
      :serial_number,
      :model,
      :equipment_type_id,
      :manufacturer_id,
      :department_id,
      :responsible_user_id,
      :status,
      :commissioned_on,
      :verification_interval_months,
      :last_verified_on,
      :next_verification_on,
      :location,
      :notes
    )
  end
end