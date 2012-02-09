# coding: utf-8  
require "digest/md5"

class Reply < ActiveRecord::Base
  
  belongs_to :user,   :counter_cache => true, :inverse_of => :replies
  belongs_to :topic,  :counter_cache => true, :inverse_of => :replies
  has_many :notifications, :class_name => 'Notification::Base', :dependent => :delete_all
  
  serialize :mentioned_user_ids, Array
  attr_protected :user_id, :topic_id, :email_key

  validates_presence_of :body
  
  scope :recent, order("id DESC")

  after_create :update_parent_topic
  def update_parent_topic
    topic.update_last_reply(self)
  end

  before_save :extract_mentioned_users
  def extract_mentioned_users
    logins = body.scan(/@(\w{3,20})/).flatten
    if logins.any?
      self.mentioned_user_ids = User.where(:login => logins).limit(5).map(&:id)
    end
  end

  before_save :generate_email_key
  def generate_email_key
    self.email_key = Digest::MD5.hexdigest(rand.to_s)
  end

  def mentioned_user_logins
    # 用于作为缓存 key
    ids_md5 = Digest::MD5.hexdigest(self.mentioned_user_ids.to_s)
    Rails.cache.fetch("reply:#{self.id}:mentioned_user_logins:#{ids_md5}") do
      User.where(:id => self.mentioned_user_ids).map(&:login)
    end
  end

  after_create :send_mention_notification
  def send_mention_notification
    self.mentioned_user_ids.each do |user_id|
      Notification::Mention.create :user_id => user_id, :reply => self
    end
  end

  after_create :send_notify_reply_mail
  def send_notify_reply_mail
    if topic.id == 4
      # XXX: 避免歡迎信騷擾大家 need_refactor
      return true
      return 
    end
    # fetch follower ids from the topic (may or may not include the topic author)
    recipient_ids = Set.new(topic.follower_ids)
    
    # don't send reply notification to the author of the reply
    recipient_ids.delete(user.id)

    # add the topic author to the recipients, if he is not the reply author
    recipient_ids.add(topic.user.id) if topic.user.id != user.id

    # prevent duplicated mail sent to users mentioned in the reply
    recipient_ids.subtract(mentioned_user_ids)

    recipient_ids.each do |recipient_id|
      TopicMailer.notify_reply(recipient_id, topic.id, self.id).deliver
    end
    
    return true
  end
end
