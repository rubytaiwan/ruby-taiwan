# coding: utf-8
class Mongodb::SiteNode
  
  include Mongoid::Document
  include Mongoid::BaseModel
  store_in :site_nodes
  
  field :name
  field :sites_count, :type => Integer
  field :sort, :type => Integer, :default => 0
  has_many :sites, :class_name => "Mongodb::Site"
end
