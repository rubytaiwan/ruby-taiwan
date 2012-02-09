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
