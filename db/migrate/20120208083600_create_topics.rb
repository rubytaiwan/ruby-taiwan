class CreateTopics < ActiveRecord::Migration
  def change
    create_table :topics, :force => true do |t|
      t.string      :title,             :null => false
      t.text        :body,              :null => false
      t.string      :source

      t.references  :node
      t.references  :user

      t.integer     :message_id

      t.integer     :replies_count,                       :default => 0
      t.integer     :likes_count,                         :default => 0
      t.integer     :visit_count,                         :default => 0

      t.timestamps
      t.datetime    :suggested_at
      t.datetime    :replied_at

    end

    add_index :topics, :node_id
    add_index :topics, :user_id
    add_index :topics, :replied_at
    add_index :topics, :suggested_at
  end
end