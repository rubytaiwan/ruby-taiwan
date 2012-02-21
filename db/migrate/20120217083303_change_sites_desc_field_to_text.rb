class ChangeSitesDescFieldToText < ActiveRecord::Migration
  def change
    change_column :sites, :desc, :text
  end
end