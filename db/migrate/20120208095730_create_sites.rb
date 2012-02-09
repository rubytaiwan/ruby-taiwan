class CreateSites < ActiveRecord::Migration
  def change
    create_table :sites, :force => true do |t|
      t.string  :name, :null => false
      t.string  :url,  :null => false
      t.string  :desc
      t.string  :favicon

      t.references :site_node

      t.timestamps
    end

    add_index :sites, :site_node_id
  end
end