class CreateAuditLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :audit_logs do |t|
      t.references :user, null: true, foreign_key: true
      t.references :auditable, polymorphic: true, null: false
      t.string :action, null: false
      t.jsonb :audited_changes, null: false, default: {}
      t.inet :ip_address
      t.string :user_agent
      t.datetime :created_at, null: false, default: -> { "CURRENT_TIMESTAMP" }
    end

    add_index :audit_logs, [:auditable_type, :auditable_id, :created_at], name: "index_audit_logs_on_auditable_and_created_at"
    add_index :audit_logs, :action
  end
end