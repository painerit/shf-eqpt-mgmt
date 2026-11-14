class CreateEquipmentTypes < ActiveRecord::Migration[7.0]
  def change
    create_table :equipment_types do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :equipment_types, :code, unique: true
  end
end