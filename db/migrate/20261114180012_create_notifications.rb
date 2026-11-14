class CreateNotifications < ActiveRecord::Migration[7.0]
  def change
    create_table :notifications do |t|
      t.references :user, null: false, foreign_key: { on_delete: :cascade }
      t.references :notifiable, polymorphic: true, null: false
      t.string :kind, null: false
      t.text :message, null: false
      t.date :due_on
      t.datetime :read_at
      t.timestamps
    end

    add_index :notifications,
              [:user_id, :notifiable_type, :notifiable_id, :kind, :due_on],
              unique: true,
              name: "index_notifications_unique_event"
    add_index :notifications, [:user_id, :read_at]
  end
end