# coding: utf-8  
class Node < ActiveRecord::Base
  
  has_many :topics
  belongs_to :section
  
  
  validates_presence_of :name, :summary, :section
  validates_uniqueness_of :name
  
  has_many :followings, :as => :followable
  has_many :followers, :through => :followings, :class_name => 'User', :inverse_of => :followings

  scope :hots, order("topics_count DESC")
  scope :sorted, order("sort DESC")
  
  after_save do
    # 记录节点变更时间，用于清除缓存
    CacheVersion.section_node_updated_at = Time.now
  end
  
  # 热门节电给 select 用的
  def self.hot_node_collection
    Rails.cache.fetch("node:hot_node_collection:#{CacheVersion.section_node_updated_at}") do
      Node.hots.collect { |n| [n.name,n.id] }
    end
  end
end
