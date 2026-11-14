class CreateVerificationResults < ActiveRecord::Migration[7.0]
  def change
    create_table :verification_results do |t|
      t.references :verification, null: false, foreign_key: { on_delete: :cascade }
      t.string :parameter_name, null: false
      t.string :unit
      t.decimal :measured_value, precision: 12, scale: 4
      t.decimal :reference_value, precision: 12, scale: 4
      t.decimal :tolerance, precision: 12, scale: 4
      t.boolean :passed, null: false, default: false
      t.datetime :measured_at
      t.jsonb :raw_payload, null: false, default: {}
      t.timestamps
    end
  end
end