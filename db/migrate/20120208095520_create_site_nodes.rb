class CreateSiteNodes < ActiveRecord::Migration
  def change
    create_table :site_nodes, :force => true do |t|
      t.string :name,         :null => false
      t.integer :sort,        :default => 0
      t.integer :sites_count, :default => 0

      t.timestamps
    end
  end
end