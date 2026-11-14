class CreateUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :users do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :full_name, null: false
      t.string :phone
      t.references :role, null: false, foreign_key: true
      t.references :department, null: true, foreign_key: true
      t.boolean :active, null: false, default: true
      t.timestamps
    end

    add_index :users, "lower(email)", unique: true, name: "index_users_on_lower_email"
  end
end