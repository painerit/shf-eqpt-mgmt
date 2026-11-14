class CreateEquipment < ActiveRecord::Migration[7.0]
  def change
    create_table :equipment do |t|
      t.string :inventory_number, null: false
      t.string :serial_number, null: false
      t.string :model, null: false
      t.references :equipment_type, null: false, foreign_key: true
      t.references :manufacturer, null: false, foreign_key: true
      t.references :department, null: false, foreign_key: true
      t.references :responsible_user, null: true, foreign_key: { to_table: :users }
      t.string :status, null: false, default: "in_service"
      t.date :commissioned_on
      t.integer :verification_interval_months, null: false, default: 12
      t.date :last_verified_on
      t.date :next_verification_on
      t.string :location
      t.text :notes
      t.timestamps
    end

    add_index :equipment, :inventory_number, unique: true
    add_index :equipment, [:manufacturer_id, :serial_number], unique: true
    add_index :equipment, :next_verification_on
    add_index :equipment, :status
    add_check_constraint :equipment, "verification_interval_months > 0", name: "equipment_verification_interval_positive"
  end
end