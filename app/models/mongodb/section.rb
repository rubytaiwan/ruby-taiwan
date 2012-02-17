# coding: utf-8  
class Mongodb::Section

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  store_in :sections

  field :name
  field :sort, :type => Integer, :default => 0
  has_many :nodes, :class_name => "Mongodb::Node", :dependent => :destroy
end
