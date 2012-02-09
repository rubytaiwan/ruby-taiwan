class CreateSiteConfigs < ActiveRecord::Migration
  def change
    create_table :site_configs, :force => true do |t|
      t.string :key,  :null => false
      t.string :value
      t.timestamps
    end

    add_index :site_configs, :key
  end
end