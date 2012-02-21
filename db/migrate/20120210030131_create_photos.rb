class CreatePhotos < ActiveRecord::Migration
  def self.up
    create_table :photos, :force => true do |t|
      t.string :image
      t.references :user

      t.timestamps
    end
  end

  def self.down
    drop_table :photos
  end
end