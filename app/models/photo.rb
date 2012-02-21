# coding: utf-8  
class Photo < ActiveRecord::Base
  belongs_to :user, :inverse_of => :photos
  
  attr_protected :user_id
  

  scope :recent, order("id DESC")

  # 封面图
  mount_uploader :image, PhotoUploader
  
end

# == Schema Information
#
# Table name: photos
#
#  id         :integer(4)      not null, primary key
#  image      :string(255)
#  user_id    :integer(4)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

