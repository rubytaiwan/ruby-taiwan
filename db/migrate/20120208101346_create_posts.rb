class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts, :force => true do |t|
      t.string     :title, :null => false
      t.text       :body,  :null => false
      t.references :user
      t.integer    :state,                 :default => Post::STATE[:draft]

      t.string     :source
      t.string     :source_url

      t.integer    :comments_count,        :default => 0
      t.integer    :visit_count,           :default => 0

      t.timestamps
    end

    add_index :posts, :user_id
    add_index :posts, :state
  end
end