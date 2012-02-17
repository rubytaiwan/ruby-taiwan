# coding: utf-8  
class Mongodb::Node
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  store_in :nodes

  field :name
  field :summary
  field :sort, :type => Integer, :default => 0
  field :topics_count, :type => Integer, :default => 0
  
  has_many :topics, :class_name => "Mongodb::Topic"
  belongs_to :section, :class_name => "Mongodb::Section"
  
  index :section_id
  
  has_and_belongs_to_many :followers, :class_name => 'Mongodb::User', :inverse_of => :following_nodes
end
