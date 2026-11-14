class CreateDocumentCounters < ActiveRecord::Migration[7.0]
  def change
    create_table :document_counters do |t|
      t.string :kind, null: false
      t.integer :year, null: false
      t.integer :value, null: false, default: 0
      t.timestamps
    end

    add_index :document_counters, [:kind, :year], unique: true
    add_check_constraint :document_counters, "value >= 0", name: "document_counters_value_non_negative"
    add_check_constraint :document_counters, "year > 2000", name: "document_counters_year_valid"
  end
end