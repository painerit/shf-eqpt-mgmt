class CreateNormativeDocuments < ActiveRecord::Migration[7.0]
  def change
    create_table :normative_documents do |t|
      t.string :doc_number, null: false
      t.string :title, null: false
      t.string :doc_type, null: false, default: "other"
      t.date :issued_on
      t.date :valid_until
      t.string :url
      t.text :description
      t.timestamps
    end

    add_index :normative_documents, :doc_number, unique: true
  end
end