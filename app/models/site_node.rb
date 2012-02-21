# coding: utf-8
class SiteNode < ActiveRecord::Base
  has_many :sites, :inverse_of => :site_node
  
  validates_presence_of :name
  validates_uniqueness_of :name
end
