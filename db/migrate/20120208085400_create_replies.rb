class CreateReplies < ActiveRecord::Migration
  def change
    create_table :replies, :force => true do |t|

      t.text          :body, :null => false
      t.references    :topic
      t.references    :user
      t.text          :mentioned_user_ids   # serialized

      t.string        :source
      t.string        :message_id           # UUID
      t.string        :email_key

      t.timestamps

    end

    add_index :replies, :topic_id
    add_index :replies, :user_id
  end
end