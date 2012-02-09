class CreateNodes < ActiveRecord::Migration
  def change
    create_table :nodes, :force => true do |t|
      t.string      :name,          :null => false
      t.references  :section,       :null => false
      t.integer     :sort,          :null => false, :default => 0
      t.string      :summary
      t.integer     :topics_count,                  :default => 0

      t.timestamps
    end

    add_index :nodes, :section_id
  end
end