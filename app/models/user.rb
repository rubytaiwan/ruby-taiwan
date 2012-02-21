# coding: utf-8  
class User < ActiveRecord::Base
  include Redis::Objects

  attr_accessible :email, :password, :password_confirmation, :remember_me
  extend OmniauthCallbacks   

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable

  # don't remove contents when the user is killed
  has_many :topics,   :inverse_of => :user
  has_many :replies,  :inverse_of => :user
  has_many :posts,    :inverse_of => :user
  has_many :comments, :inverse_of => :user
  has_many :notes,    :inverse_of => :user
  has_many :photos,   :inverse_of => :user

  # remove likes, followings, authorizations and notifications when user is killed
  has_many :likes,          :dependent => :destroy
  has_many :followings,     :dependent => :destroy
  has_many :authorizations, :dependent => :destroy
  has_many :notifications,  :dependent => :delete_all, :class_name => 'Notification::Base'

  # users who follow me
  # TODO: Uncomment this when we're going to implement User-following feature
  # has_many :followers, :class_name => "User", :through => :followings, :source => :user

  # I follow users
  # TODO: Uncomment this when we're going to implement User-following feature
  # has_many :following_users,        :class_name => "User",  :uniq => true,
  #          :through => :followings, :source => :followable, :source_type => :user

  # I follow nodes
  # TODO: Uncomment this when we're going to implement Node-following feature
  # has_many :following_nodes,        :class_name => "Node",  :uniq => true,
  #          :through => :followings, :source => :followable, :source_type => :node

  # I follow topics
  has_many :following_topics,       :class_name => "Topic", :uniq => true,
           :through => :followings, :source => :followable, :source_type => :topic

  def read_notifications(notifications)
    self.notifications.mark_all_as_read!
  end

  # State machine definition
  state_machine :initial => :normal do
    state :deleted
    state :blocked

    before_transition any => [:blocked, :deleted], :do => :revoke_verified!
    after_transition any => :deleted, :do => :remove_authorizations!

    event :block do
      transition :normal => :blocked
    end

    event :unblock do
      transition :blocked => :normal
    end

    event :soft_delete do
      transition [:normal, :blocked] => :deleted
    end

    event :restore do
      transition :deleted => :normal
    end
  end

  attr_accessor :password_confirmation
  attr_protected :replies_count
  
  validates :login, :format => {:with => /\A\w+\z/, :message => '只允许数字、大小写字母和下划线'}, :length => {:in => 3..20}, :presence => true, :uniqueness => {:case_sensitive => false}

  scope :recent, order("id DESC")
  scope :hot, order("replies_count DESC, topics_count DESC")

  scope :normal,  with_state(:normal)
  scope :deleted, with_state(:deleted)
  scope :not_deleted, without_state(:deleted)
  scope :blocked, with_state(:blocked)

  default_scope not_deleted

  # grab stats of locations:
  #
  # location_name | users_count
  # --------------+-------------
  # Taihoku       | 32
  # Matsuyama     | 18
  #
  # and map it into a hash with
  #  {:location => location_name, :count => users_count}
  def self.locations(options={})
    # We actually get User instances with location_name and users_count attributes
    fake_users = User.select("location as location_name, COUNT(*) as users_count").group(:location)

    fake_users = fake_users.order(options[:order]) if options[:order]
    fake_users = fake_users.limit(options[:limit]) if options[:limit]

    fake_users.map { |fake_user|
      {:location => fake_user.location_name, :count => fake_user.users_count}
    }
  end

  def self.most_popular_locations(limit=12)
    self.locations(:order => "users_count DESC", :limit => limit)
  end

  def self.find_for_database_authentication(conditions)
    login = conditions.delete(:login)
    self.where("lower(login) = ?", login.downcase).first
  end

  def password_required?
    return false if self.guest
    (authorizations.empty? || !password.blank?) && super  
  end
  
  def github_url
    return "" if self.github.blank?
    "http://github.com/#{self.github}"
  end
  
  def revoke_verified!
    self.verified = false
    self.save
  end

  def remove_authorizations!
    self.authorizations.destroy_all
  end

  # 是否是管理员
  def admin?
    return true if Setting.admin_emails.include?(self.email)
    return false
  end
  
  # 是否有 Wiki 维护权限
  def wiki_editor?
    return true if self.admin? or self.verified == true
    return false
  end
  
  def has_role?(role)
    case role
    when :admin
      return true if Setting.admin_emails.include?(self.email)
      return false 
    when :wiki_editor
      return true if self.admin? or self.verified == true
      return false
    when :member
      return true
    else
      false
    end
  end
  

  # 注册邮件提醒
  after_create :send_welcome_mail
  def send_welcome_mail
    UserMailer.welcome(self.id).deliver
  end
  
  # 用邮件地址创建一个用户
  def self.find_or_create_guest(email)
    if u = find_by_email(email)
      return u
    else
      u = new(:email => email)
      u.login = email.split("@").first
      u.guest = true
      if u.save
        return u
      else
        Rails.logger.error("find_or_create_guest failed, #{u.errors.inspect}")
      end
    end
  end
  
  def update_with_password(params={})
    if !params[:current_password].blank? or !params[:password].blank? or !params[:password_confirmation].blank?
      super
    else
      params.delete(:current_password)
      self.update_without_password(params)
    end
  end
  
  def self.find_by_email(email)
    where(:email => email).first
  end
  
  def bind?(provider)
    self.authorizations.collect { |a| a.provider }.include?(provider)
  end
  
  def bind_service(response)
    provider = response["provider"]
    uid = response["uid"]
    authorizations.create(:provider => provider , :uid => uid ) 
  end
  
  # 是否读过 topic 的最近更新
  def topic_read?(topic)
    # 用 last_reply_id 作为 cache key ，以便不热门的数据自动被 Memcached 挤掉
    last_reply_id = topic.last_reply.id rescue -1
    Rails.cache.read("user:#{self.id}:topic_read:#{topic.id}") == last_reply_id
  end

  # 将 topic 的最后回复设置为已读
  def read_topic(topic)
    # 处理 last_reply_id 是空的情况
    last_reply_id = topic.last_reply.id rescue -1
    Rails.cache.write("user:#{self.id}:topic_read:#{topic.id}", last_reply_id)
  end
  
  # 收藏东西
  def like(likeable)
    Like.find_or_create_by(:likeable_id => likeable.id, 
                           :likeable_type => likeable.class,
                           :user_id => self.id)
  end
  
  # 取消收藏
  def unlike(likeable)
    Like.destroy_all(:conditions => {:likeable_id => likeable.id, 
                                     :likeable_type => likeable.class,
                                     :user_id => self.id})
  end
end

# == Schema Information
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  login                :string(255)     not null
#  location             :string(255)
#  tagline              :string(255)
#  bio                  :text
#  website              :string(255)
#  github               :string(255)
#  verified             :boolean(1)      default(TRUE)
#  guest                :boolean(1)      default(FALSE)
#  topics_count         :integer(4)      default(0)
#  replies_count        :integer(4)      default(0)
#  likes_count          :integer(4)      default(0)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)      default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  state                :string(255)     default("normal")
#

