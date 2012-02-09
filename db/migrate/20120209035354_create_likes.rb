class CreateLikes < ActiveRecord::Migration
  def change
    create_table :likes, :force => true do |t|
      t.references :likeable, :polymorphic => true
      t.references :user
      t.timestamps
    end

    add_index :likes, :likeable_id
    add_index :likes, :likeable_type
    add_index :likes, :user_id
  end
end