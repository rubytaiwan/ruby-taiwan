# coding: utf-8
class Topic < ActiveRecord::Base
  include Redis::Objects

  belongs_to :user, :counter_cache => true, :inverse_of => :topics
  belongs_to :node, :counter_cache => true, :inverse_of => :topics
  belongs_to :last_reply_user, :class_name => 'User'
  has_many :replies, :dependent => :destroy

  attr_protected :user_id
  validates_presence_of :user_id, :title, :body, :node_id

  search_in :title, :body

  

  counter :hits, :default => 0

  # scopes
  scope :recent, order("id DESC")
  scope :last_actived, order("replied_at DESC, created_at DESC")
  # 推荐的话题
  scope :suggest, where("suggested_at IS NOT NULL").order("suggested_at DESC")
  before_save :set_replied_at
  def set_replied_at
    self.replied_at = Time.now
  end

  def node_name
    node.try(:name) || ""
  end

  def push_follower(user_id)
    self.follower_ids << user_id if !self.follower_ids.include?(user_id)
  end

  def pull_follower(user_id)
    self.follower_ids.delete(user_id)
  end
  
  def update_last_reply(reply)
    self.replied_at = Time.now
    self.last_reply_id = reply.id
    self.last_reply_user_id = reply.user_id
    self.push_follower(reply.user_id)
    self.save
  end

  def self.find_by_message_id(message_id)
    where(:message_id => message_id).first
  end
end
