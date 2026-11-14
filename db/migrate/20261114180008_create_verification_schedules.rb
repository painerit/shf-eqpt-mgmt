class CreateVerificationSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :verification_schedules do |t|
      t.references :equipment, null: false, foreign_key: true
      t.references :normative_document, null: true, foreign_key: true
      t.references :responsible_user, null: true, foreign_key: { to_table: :users }
      t.date :planned_on, null: false
      t.integer :period_year, null: false
      t.string :status, null: false, default: "planned"
      t.text :notes
      t.timestamps
    end

    add_index :verification_schedules, [:equipment_id, :planned_on], unique: true
    add_index :verification_schedules, :planned_on
    add_index :verification_schedules, :status
  end
end