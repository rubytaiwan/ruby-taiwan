class RedefineStateFieldOnUsers < ActiveRecord::Migration
  def change
    remove_column :users, :state

    add_column    :users, :state, :string, :default => "normal"
    add_index     :users, :state
  end
end