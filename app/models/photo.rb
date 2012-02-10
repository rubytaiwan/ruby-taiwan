# coding: utf-8  
class Photo < ActiveRecord::Base
  belongs_to :user
  
  attr_protected :user_id
  

  scope :recent, order("id DESC")

  # 封面图
  mount_uploader :image, PhotoUploader
  
end
