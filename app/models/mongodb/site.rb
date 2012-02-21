# coding: utf-8
class Mongodb::Site
  
  include Mongoid::Document
  include Mongoid::BaseModel
  include Mongoid::Timestamps
  include Mongoid::CounterCache
  store_in :sites
  
  field :name
  field :url
  field :desc
  field :favicon
  
  belongs_to :site_node, :class_name => "Mongodb::SiteNode"
  counter_cache :name => :site_node, :inverse_of => :sites
  belongs_to :user, :class_name => "Mongodb::User"
end
