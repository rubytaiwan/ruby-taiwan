class CreateFollowings < ActiveRecord::Migration
  def change
    create_table :followings do |t|
      t.references :followable, :polymorphic => true
      t.references :user

      t.timestamps
    end

    add_index :followings, :followable_id
    add_index :followings, :followable_type
    add_index :followings, :user_id
  end
end
