# coding: utf-8  
# 记事本
class Mongodb::Note  
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  store_in :notes
  
  field :title
  field :body
  field :word_count, :type => Integer
  field :changes_count, :type =>  Integer, :default => 0
  field :publish, :type => Boolean, :default => false
  belongs_to :user, :class_name => "Mongodb::User"
  
  index :user_id
end
