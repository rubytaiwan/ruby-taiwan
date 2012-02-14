# coding: utf-8
class Post < ActiveRecord::Base
  include Redis::Objects
  
  STATE = {
    :draft => 0,
    :normal => 1
  }
  
  belongs_to :user
  
  
  attr_protected :state, :user_id

  acts_as_taggable

  validates_presence_of :title, :body, :tag_list
  
  scope :recent, order("id DESC")
  scope :normal, where(:state => STATE[:normal])

  # 给下拉框用
  def self.state_collection
    STATE.collect { |s| [s[0], s[1]]}
  end
  
  def visit
    self.class.increment_counter(:visit_count, self.id)
  end

end
