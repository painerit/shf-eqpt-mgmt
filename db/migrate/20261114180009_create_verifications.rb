class CreateVerifications < ActiveRecord::Migration[7.0]
  def change
    create_table :verifications do |t|
      t.references :verification_schedule, null: true, foreign_key: true
      t.references :equipment, null: false, foreign_key: true
      t.references :performed_by, null: true, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "planned"
      t.date :performed_on
      t.datetime :completed_at
      t.string :protocol_number
      t.string :certificate_number
      t.text :conclusion
      t.string :external_id
      t.string :external_status
      t.datetime :external_synced_at
      t.text :external_error
      t.timestamps
    end

    add_index :verifications, :protocol_number, unique: true, where: "protocol_number IS NOT NULL"
    add_index :verifications, :certificate_number, unique: true, where: "certificate_number IS NOT NULL"
    add_index :verifications, [:equipment_id, :performed_on]
    add_index :verifications, :status
    add_index :verifications, :external_id
  end
end