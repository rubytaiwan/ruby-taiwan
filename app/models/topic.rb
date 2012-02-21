# coding: utf-8
class Topic < ActiveRecord::Base
  include Redis::Objects

  acts_as_archive

  belongs_to :user, :counter_cache => true, :inverse_of => :topics
  belongs_to :node, :counter_cache => true, :inverse_of => :topics

  has_many :replies, :dependent => :destroy, :inverse_of => :topic

  has_many :followings, :as => :followable, :dependent => :destroy
  has_many :followers, :class_name => 'User', :through => :followings, :source => :user

  attr_protected :user_id
  validates_presence_of :user_id, :title, :body, :node_id

  # scopes
  scope :recent, order("id DESC")
  # last_actived should be order by replied_at; if replied_at is NULL, then order by created_at.
  scope :last_actived, order("IFNULL(replied_at, created_at) DESC")
  # 推荐的话题
  scope :suggest, where("suggested_at IS NOT NULL").order("suggested_at DESC")

  def node_name
    node.try(:name) || ""
  end

  def push_follower(user)
    self.followers.push(user) unless self.followers.include? user
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

# == Schema Information
#
# Table name: topics
#
#  id            :integer(4)      not null, primary key
#  title         :string(255)     not null
#  body          :text            default(""), not null
#  source        :string(255)
#  node_id       :integer(4)
#  user_id       :integer(4)
#  message_id    :integer(4)
#  replies_count :integer(4)      default(0)
#  likes_count   :integer(4)      default(0)
#  visit_count   :integer(4)      default(0)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  suggested_at  :datetime
#  replied_at    :datetime
#

