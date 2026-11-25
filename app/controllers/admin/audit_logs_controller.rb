module Admin
  class AuditLogsController < ApplicationController
    after_action :verify_authorized
    after_action :verify_policy_scoped, only: :index

    def index
      authorize AuditLog

      @audit_logs = AuditLogQuery.new(
        scope: policy_scope(AuditLog),
        params: params
      ).call.page(params[:page]).per(30)

      load_filters
    end

    def show
      @audit_log = AuditLog.find(params[:id])
      authorize @audit_log
    end

    private

    def load_filters
      @users = User.order(:full_name)
      @actions = AuditLog.distinct.order(:action).pluck(:action)
      @auditable_types = AuditLog.distinct.order(:auditable_type).pluck(:auditable_type)
    end
  end
end