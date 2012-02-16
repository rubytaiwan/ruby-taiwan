# coding: utf-8  
require "digest/md5"

class Mongodb::Reply

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::CounterCache
  store_in :replies

  field :body
  field :source
  field :message_id
  field :email_key
  field :mentioned_user_ids, :type => Array, :default => []
  
  belongs_to :user, :class_name => "Mongodb::User", :inverse_of => :replies
  belongs_to :topic, :class_name => "Mongodb::Topic", :inverse_of => :replies
  has_many :notifications, :class_name => 'Mongodb::Notification::Base', :dependent => :delete
 
  counter_cache :name => :user, :inverse_of => :replies
  counter_cache :name => :topic, :inverse_of => :replies
  
  index :user_id
  index :topic_id
end
