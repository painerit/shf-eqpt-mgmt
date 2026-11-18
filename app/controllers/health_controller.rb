class HealthController < ApplicationController
  skip_before_action :set_current_attributes
  skip_before_action :require_login

  def show
    ActiveRecord::Base.connection.execute("SELECT 1")
    render json: { status: "ok", database: "ok" }
  rescue ActiveRecord::ConnectionNotEstablished, PG::Error
    render json: { status: "error", database: "unavailable" }, status: :service_unavailable
  end
end