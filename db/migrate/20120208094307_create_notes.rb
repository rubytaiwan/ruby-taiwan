class CreateNotes < ActiveRecord::Migration
  def change
    create_table :notes, :force => true do |t|
      t.string  :title
      t.text    :body
      t.boolean :is_public,  :default => false

      t.references :user

      t.integer :word_count,    :default => 0
      t.integer :changes_count, :default => 0

      t.timestamps
    end

    add_index :notes, :user_id
  end
end