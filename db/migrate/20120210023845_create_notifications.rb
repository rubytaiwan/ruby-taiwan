class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications, :force => true do |t|
      t.string      :type,      :null => false        # Single-Table Inheritance
      t.references  :source,    :polymorphic => true
      t.references  :user
      t.boolean     :is_read,   :default => false

      t.timestamps
    end

    add_index :notifications, :type
    add_index :notifications, :source_type
    add_index :notifications, :source_id
    add_index :notifications, :user_id
    add_index :notifications, :is_read

  end
end