class CreateSections < ActiveRecord::Migration
  def change
    create_table :sections, :force => true do |t|
      t.string  :name
      t.integer :sort, :default => 0

      t.timestamps
    end
  end
end