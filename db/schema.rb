# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2026_11_14_180013) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "audit_logs", force: :cascade do |t|
    t.bigint "user_id"
    t.string "auditable_type", null: false
    t.bigint "auditable_id", null: false
    t.string "action", null: false
    t.jsonb "audited_changes", default: {}, null: false
    t.inet "ip_address"
    t.string "user_agent"
    t.datetime "created_at", default: -> { "CURRENT_TIMESTAMP" }, null: false
    t.index ["action"], name: "index_audit_logs_on_action"
    t.index ["auditable_type", "auditable_id", "created_at"], name: "index_audit_logs_on_auditable_and_created_at"
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "departments", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_departments_on_code", unique: true
  end

  create_table "document_counters", force: :cascade do |t|
    t.string "kind", null: false
    t.integer "year", null: false
    t.integer "value", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["kind", "year"], name: "index_document_counters_on_kind_and_year", unique: true
    t.check_constraint "value >= 0", name: "document_counters_value_non_negative"
    t.check_constraint "year > 2000", name: "document_counters_year_valid"
  end

  create_table "equipment", force: :cascade do |t|
    t.string "inventory_number", null: false
    t.string "serial_number", null: false
    t.string "model", null: false
    t.bigint "equipment_type_id", null: false
    t.bigint "manufacturer_id", null: false
    t.bigint "department_id", null: false
    t.bigint "responsible_user_id"
    t.string "status", default: "in_service", null: false
    t.date "commissioned_on"
    t.integer "verification_interval_months", default: 12, null: false
    t.date "last_verified_on"
    t.date "next_verification_on"
    t.string "location"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["department_id"], name: "index_equipment_on_department_id"
    t.index ["equipment_type_id"], name: "index_equipment_on_equipment_type_id"
    t.index ["inventory_number"], name: "index_equipment_on_inventory_number", unique: true
    t.index ["manufacturer_id", "serial_number"], name: "index_equipment_on_manufacturer_id_and_serial_number", unique: true
    t.index ["manufacturer_id"], name: "index_equipment_on_manufacturer_id"
    t.index ["next_verification_on"], name: "index_equipment_on_next_verification_on"
    t.index ["responsible_user_id"], name: "index_equipment_on_responsible_user_id"
    t.index ["status"], name: "index_equipment_on_status"
    t.check_constraint "verification_interval_months > 0", name: "equipment_verification_interval_positive"
  end

  create_table "equipment_types", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_equipment_types_on_code", unique: true
  end

  create_table "manufacturers", force: :cascade do |t|
    t.string "name", null: false
    t.string "country"
    t.string "website"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_manufacturers_on_name", unique: true
  end

  create_table "normative_documents", force: :cascade do |t|
    t.string "doc_number", null: false
    t.string "title", null: false
    t.string "doc_type", default: "other", null: false
    t.date "issued_on"
    t.date "valid_until"
    t.string "url"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["doc_number"], name: "index_normative_documents_on_doc_number", unique: true
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "notifiable_type", null: false
    t.bigint "notifiable_id", null: false
    t.string "kind", null: false
    t.text "message", null: false
    t.date "due_on"
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notifiable_type", "notifiable_id"], name: "index_notifications_on_notifiable"
    t.index ["user_id", "notifiable_type", "notifiable_id", "kind", "due_on"], name: "index_notifications_unique_event", unique: true
    t.index ["user_id", "read_at"], name: "index_notifications_on_user_id_and_read_at"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_roles_on_code", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.string "full_name", null: false
    t.string "phone"
    t.bigint "role_id", null: false
    t.bigint "department_id"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index "lower((email)::text)", name: "index_users_on_lower_email", unique: true
    t.index ["department_id"], name: "index_users_on_department_id"
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "verification_results", force: :cascade do |t|
    t.bigint "verification_id", null: false
    t.string "parameter_name", null: false
    t.string "unit"
    t.decimal "measured_value", precision: 12, scale: 4
    t.decimal "reference_value", precision: 12, scale: 4
    t.decimal "tolerance", precision: 12, scale: 4
    t.boolean "passed", default: false, null: false
    t.datetime "measured_at"
    t.jsonb "raw_payload", default: {}, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["verification_id"], name: "index_verification_results_on_verification_id"
  end

  create_table "verification_schedules", force: :cascade do |t|
    t.bigint "equipment_id", null: false
    t.bigint "normative_document_id"
    t.bigint "responsible_user_id"
    t.date "planned_on", null: false
    t.integer "period_year", null: false
    t.string "status", default: "planned", null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["equipment_id", "planned_on"], name: "index_verification_schedules_on_equipment_id_and_planned_on", unique: true
    t.index ["equipment_id"], name: "index_verification_schedules_on_equipment_id"
    t.index ["normative_document_id"], name: "index_verification_schedules_on_normative_document_id"
    t.index ["planned_on"], name: "index_verification_schedules_on_planned_on"
    t.index ["responsible_user_id"], name: "index_verification_schedules_on_responsible_user_id"
    t.index ["status"], name: "index_verification_schedules_on_status"
  end

  create_table "verifications", force: :cascade do |t|
    t.bigint "verification_schedule_id"
    t.bigint "equipment_id", null: false
    t.bigint "performed_by_id"
    t.string "status", default: "planned", null: false
    t.date "performed_on"
    t.datetime "completed_at"
    t.string "protocol_number"
    t.string "certificate_number"
    t.text "conclusion"
    t.string "external_id"
    t.string "external_status"
    t.datetime "external_synced_at"
    t.text "external_error"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["certificate_number"], name: "index_verifications_on_certificate_number", unique: true, where: "(certificate_number IS NOT NULL)"
    t.index ["equipment_id", "performed_on"], name: "index_verifications_on_equipment_id_and_performed_on"
    t.index ["equipment_id"], name: "index_verifications_on_equipment_id"
    t.index ["external_id"], name: "index_verifications_on_external_id"
    t.index ["performed_by_id"], name: "index_verifications_on_performed_by_id"
    t.index ["protocol_number"], name: "index_verifications_on_protocol_number", unique: true, where: "(protocol_number IS NOT NULL)"
    t.index ["status"], name: "index_verifications_on_status"
    t.index ["verification_schedule_id"], name: "index_verifications_on_verification_schedule_id"
  end

  add_foreign_key "audit_logs", "users"
  add_foreign_key "equipment", "departments"
  add_foreign_key "equipment", "equipment_types"
  add_foreign_key "equipment", "manufacturers"
  add_foreign_key "equipment", "users", column: "responsible_user_id"
  add_foreign_key "notifications", "users", on_delete: :cascade
  add_foreign_key "users", "departments"
  add_foreign_key "users", "roles"
  add_foreign_key "verification_results", "verifications", on_delete: :cascade
  add_foreign_key "verification_schedules", "equipment"
  add_foreign_key "verification_schedules", "normative_documents"
  add_foreign_key "verification_schedules", "users", column: "responsible_user_id"
  add_foreign_key "verifications", "equipment"
  add_foreign_key "verifications", "users", column: "performed_by_id"
  add_foreign_key "verifications", "verification_schedules"
end
