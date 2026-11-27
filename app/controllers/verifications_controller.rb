class VerificationsController < ApplicationController
  before_action :set_verification, only: [:show, :edit, :update, :start, :complete, :cancel, :protocol, :publish]

  after_action :verify_authorized, except: :index
  after_action :verify_policy_scoped, only: :index

  def index
    authorize Verification

    @query = VerificationQuery.new(scope: policy_scope(Verification), params: params)
    @verifications = @query.call.page(params[:page]).per(20)
    load_filter_collections
  end

  def show
    authorize @verification

    @audit_logs = if current_user.customer?
                    AuditLog.none
                  else
                    @verification.audit_logs.includes(:user).recent.limit(10)
                  end
  end

  def create
    schedule = VerificationSchedule.find(params.dig(:verification, :verification_schedule_id))

    @verification = Verification.new(
      verification_schedule: schedule,
      equipment: schedule.equipment,
      performed_by: current_user,
      performed_on: Date.current,
      status: "in_progress"
    )
    authorize @verification

    if @verification.save
      record_audit(@verification, "create", @verification.saved_changes)
      redirect_to edit_verification_path(@verification), notice: "Поверка начата. Внесите результаты измерений."
    else
      redirect_to verification_schedule_path(schedule), alert: "Не удалось начать поверку."
    end
  rescue ActiveRecord::RecordNotFound
    redirect_to verification_schedules_path, alert: "Пункт графика не найден."
  end

  def edit
    authorize @verification
    prepare_form
  end

  def update
    authorize @verification

    if params[:commit_action] == "complete"
      authorize @verification, :complete?
      complete_verification
    else
      save_draft
    end
  end

  def start
    authorize @verification, :start?

    @verification.update!(
      status: "in_progress",
      performed_by: current_user,
      performed_on: @verification.performed_on || Date.current
    )
    record_audit(@verification, "start", @verification.saved_changes)

    redirect_to edit_verification_path(@verification), notice: "Поверка переведена в работу."
  end

  def complete
    authorize @verification, :complete?
    complete_verification
  end

  def cancel
    authorize @verification, :cancel?

    @verification.update!(status: "canceled", completed_at: Time.current)
    record_audit(@verification, "cancel", @verification.saved_changes)

    redirect_to verification_path(@verification), notice: "Поверка отменена."
  end

  def protocol
    authorize @verification, :protocol?

    respond_to do |format|
      format.html
      format.pdf do
        send_data Verifications::ProtocolPdf.new(@verification).render,
                  filename: "protocol-#{@verification.protocol_number.presence || @verification.id}.pdf",
                  type: "application/pdf",
                  disposition: "inline"
      end
    end
  end

  def publish
    authorize @verification, :publish?

    PublishVerificationJob.perform_later(@verification.id)
    redirect_to verification_path(@verification),
                notice: "Публикация во внешний реестр поставлена в очередь."
  end

  private

  def set_verification
    @verification = Verification.find(params[:id])
  end

  def load_filter_collections
    @departments = Department.active.order(:name)
    @verification_statuses = Verification.statuses.keys
  end

  def prepare_form
    return if @verification.verification_results.any?

    3.times { @verification.verification_results.build }
  end

  def save_draft
    if @verification.update(verification_params)
      record_audit(@verification, "update", @verification.saved_changes)
      redirect_to edit_verification_path(@verification), notice: "Черновик поверки сохранён."
    else
      prepare_form
      render :edit, status: :unprocessable_entity
    end
  end

  def complete_verification
    Verifications::Complete.new(
      verification: @verification,
      user: current_user,
      attributes: verification_params
    ).call

    redirect_to verification_path(@verification), notice: "Поверка завершена."
  rescue ActiveRecord::RecordInvalid
    prepare_form
    flash.now[:alert] = @verification.errors.full_messages.to_sentence.presence || "Проверьте результаты поверки."
    render :edit, status: :unprocessable_entity
  end

  def record_audit(verification, action, changes)
    return if changes.blank?

    AuditLog.record!(
      auditable: verification,
      user: current_user,
      action: action,
      audited_changes: changes,
      ip_address: Current.request_ip,
      user_agent: Current.user_agent
    )
  end

  def verification_params
    params.require(:verification).permit(
      :performed_on,
      :conclusion,
      verification_results_attributes: [
        :id,
        :parameter_name,
        :unit,
        :measured_value,
        :reference_value,
        :tolerance,
        :passed,
        :measured_at,
        :_destroy
      ]
    )
  end
end