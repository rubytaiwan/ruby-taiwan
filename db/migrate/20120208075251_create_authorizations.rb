class CreateAuthorizations < ActiveRecord::Migration
  def change
    create_table :authorizations, :force => true do |t|
      t.references :user,      :null => false
      t.string     :provider,  :null => false
      t.integer    :uid,       :null => false

      t.timestamps
    end

    add_index :authorizations, :user_id
  end
end