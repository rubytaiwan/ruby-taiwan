# coding: utf-8  
class Section < ActiveRecord::Base

  has_many :nodes, :dependent => :destroy
  
  validates_presence_of :name
  validates_uniqueness_of :name
  
  
  default_scope order("sort DESC")
  
  after_save do
    # 记录节点变更时间，用于清除缓存
    CacheVersion.section_node_updated_at = Time.now
  end
end

# == Schema Information
#
# Table name: sections
#
#  id         :integer(4)      not null, primary key
#  name       :string(255)
#  sort       :integer(4)      default(0)
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

