class CreateComments < ActiveRecord::Migration
  def change
    create_table :comments, :force => true do |t|
      t.text :body
      t.references :user
      t.references :commentable, :polymorphic => true

      t.timestamps
    end

    add_index :comments, :user_id
    add_index :comments, :commentable_id
    add_index :comments, :commentable_type
  end
end