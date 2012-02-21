# coding: utf-8
class SiteNode < ActiveRecord::Base
  has_many :sites, :inverse_of => :site_node
  
  validates_presence_of :name
  validates_uniqueness_of :name
end

# == Schema Information
#
# Table name: site_nodes
#
#  id          :integer(4)      not null, primary key
#  name        :string(255)     not null
#  sort        :integer(4)      default(0)
#  sites_count :integer(4)      default(0)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

