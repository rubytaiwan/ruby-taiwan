# coding: utf-8  
require "digest/md5"
class Reply
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::CounterCache
  include Mongoid::SoftDelete

  field :body
  field :source  
  field :message_id
  field :mentioned_user_ids, :type => Array, :default => []
  
  belongs_to :user, :inverse_of => :replies
  belongs_to :topic, :inverse_of => :replies
  has_many :notifications, :class_name => 'Notification::Base', :dependent => :delete
 
  counter_cache :name => :user, :inverse_of => :replies
  counter_cache :name => :topic, :inverse_of => :replies
  
  index :user_id
  index :topic_id
  
  attr_protected :user_id, :topic_id

  validates_presence_of :body
  
  after_create :update_parent_topic
  def update_parent_topic
    topic.update_last_reply(self)
  end

  before_save :extract_mentioned_users
  def extract_mentioned_users
    logins = body.scan(/@(\w{3,20})/).flatten
    if logins.any?
      self.mentioned_user_ids = User.where(:login => /^(#{logins.join('|')})$/i, :_id.ne => user.id).limit(5).only(:_id).map(&:_id).to_a
    end
  end

  def mentioned_user_logins
    # 用于作为缓存 key
    ids_md5 = Digest::MD5.hexdigest(self.mentioned_user_ids.to_s)
    Rails.cache.fetch("reply:#{self.id}:mentioned_user_logins:#{ids_md5}") do
      User.where(:_id.in => self.mentioned_user_ids).only(:login).map(&:login)
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

    # fetch follower ids from the topic (may or may not include the topic author)
    recipient_ids = Set.new(topic.follower_ids)

    # don't send reply notification to the author of the reply
    recipient_ids.delete(user.id)

    # add the topic author to the recipients, if he is not the reply author
    recipient_ids.add(topic.user.id) if topic.user.id != user.id

    # prevent duplicated mail sent to users mentioned in the reply
    recipient_ids.subtract(mentioned_user_ids)

    # for each recipientsm send email notification
    recipient_ids.to_a.each do |recipient_id|
      TopicMailer.notify_reply(recipient_id, topic.id, self.id).deliver
    end
  end
end
