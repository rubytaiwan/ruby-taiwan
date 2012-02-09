# coding: utf-8
class Topic < ActiveRecord::Base
  include Redis::Objects

  belongs_to :user, :counter_cache => true, :inverse_of => :topics
  belongs_to :node, :counter_cache => true, :inverse_of => :topics

  has_many :replies, :dependent => :destroy, :inverse_of => :topic

  has_many :followings, :as => :followable
  has_many :followers, :class_name => 'User', :through => :followings, :source => :user

  attr_protected :user_id
  validates_presence_of :user_id, :title, :body, :node_id

  search_in :title, :body

  


  # scopes
  scope :recent, order("id DESC")
  scope :last_actived, order("replied_at DESC, created_at DESC")
  # 推荐的话题
  scope :suggest, where("suggested_at IS NOT NULL").order("suggested_at DESC")

  def node_name
    node.try(:name) || ""
  end

  def push_follower(user)
    self.followers.push(user)
  end

  def pull_follower(user)
    self.followers.delete(user)
  end

  def last_reply
    replies.recent.limit(1).first
  end

  def update_replied_at(reply)
    self.replied_at = reply.created_at
    self.save
  end

  def self.find_by_message_id(message_id)
    where(:message_id => message_id).first
  end

  def visit
    self.class.increment_counter(:visit_count, self.id)
  end
end
