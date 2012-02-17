# coding: utf-8
# 喜欢
# 多态设计，可以用于收藏 Topic, Page, Post ...
class Mongodb::Like
  
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::BaseModel
  store_in :likes
  
  belongs_to :likeable, :polymorphic => true
  belongs_to :user, :class_name => "Mongodb::User"
  
  index :user_id
  index [:user_id,:likeable_type, :likeable_id]
  
end