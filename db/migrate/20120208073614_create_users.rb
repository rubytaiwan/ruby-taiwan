class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users, :force => true do |t|
      t.string  :login,           :null => false

      t.string  :location
      t.string  :tagline
      t.string  :bio

      t.string  :website
      t.string  :github

      t.boolean :verified,        :default => true
      t.boolean :guest,           :default => false
      t.integer :state,           :default => 1

      t.integer :topics_count,    :default => 0
      t.integer :replies_count,   :default => 0
      t.integer :likes_count,     :default => 0

      t.timestamps
    end

    add_index :users, :login
    add_index :users, :location
  end

end