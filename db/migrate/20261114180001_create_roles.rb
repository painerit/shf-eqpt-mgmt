class CreateRoles < ActiveRecord::Migration[7.0]
  def change
    create_table :roles do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end

    add_index :roles, :code, unique: true
  end
end