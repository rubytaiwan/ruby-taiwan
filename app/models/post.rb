# coding: utf-8
class Post < ActiveRecord::Base
  include Redis::Objects
  
  STATE = {
    :draft => 0,
    :normal => 1
  }
  
  belongs_to :user
  
  
  counter :hits, :default => 0
  
  attr_protected :state, :user_id
  attr_accessor :tag_list
  
  validates_presence_of :title, :body, :tag_list
  
  scope :recent, order("id DESC")
  scope :normal, where(:state => STATE[:normal])
  scope :by_tag, Proc.new { |t| where(:tags => t) }
  
  before_save :split_tags
  def split_tags
    if !self.tag_list.blank? and self.tags.blank?
      self.tags = self.tag_list.split(/,|，/).collect { |tag| tag.strip }.uniq
    end
  end
  
  # 给下拉框用
  def self.state_collection
    STATE.collect { |s| [s[0], s[1]]}
  end
  
end
