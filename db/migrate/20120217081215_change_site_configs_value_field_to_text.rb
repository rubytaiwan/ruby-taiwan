class ChangeSiteConfigsValueFieldToText < ActiveRecord::Migration
  def change
    change_column :site_configs, :value, :text
  end
end