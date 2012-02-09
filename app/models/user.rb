# coding: utf-8  
class User < ActiveRecord::Base
  include Redis::Objects

  attr_accessible :email, :password, :password_confirmation, :remember_me
  extend OmniauthCallbacks   

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :omniauthable
         
    

  has_many :topics, :dependent => :destroy, :inverse_of => :user
  has_many :notes
  has_many :replies, :dependent => :destroy, :inverse_of => :user
  has_many :posts
  has_many :notifications, :class_name => 'Notification::Base', :dependent => :delete_all
  has_many :photos
  has_many :likes

  def read_notifications(notifications)
    unread_ids = notifications.find_all{|notification| !notification.read?}.map(&:_id)
    if unread_ids.any?
      Notification::Base.where({
        :user_id => id,
        :_id.in  => unread_ids,
        :read    => false
      }).update_all(:read => true)
    end
  end

  attr_accessor :password_confirmation
  attr_protected :verified, :replies_count
  
  validates :login, :format => {:with => /\A\w+\z/, :message => '只允许数字、大小写字母和下划线'}, :length => {:in => 3..20}, :presence => true, :uniqueness => {:case_sensitive => false}
  
  has_and_belongs_to_many :following_nodes, :class_name => 'Node', :inverse_of => :followers
  has_and_belongs_to_many :following, :class_name => 'User', :inverse_of => :followers
  has_and_belongs_to_many :followers, :class_name => 'User', :inverse_of => :following

  scope :recent, order("id DESC")
  scope :hot, order("replies_count DESC, topics_count DESC")

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
    self.where(:login => /^#{login}$/i).first
  end

  def password_required?
    return false if self.guest
    (authorizations.empty? || !password.blank?) && super  
  end
  
  def github_url
    return "" if self.github.blank?
    "http://github.com/#{self.github}"
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
  
  before_create :default_value_for_create
  def default_value_for_create
    self.state = STATE[:normal]
  end
  
  # 注册邮件提醒
  after_create :send_welcome_mail
  def send_welcome_mail
    UserMailer.welcome(self.id).deliver
  end

  STATE = {
    # 软删除
    :deleted => -1,
    # 正常
    :normal => 1,
    # 屏蔽
    :blocked => 2,
    
  }
  
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
    last_reply_id = topic.last_reply_id || -1
    Rails.cache.read("user:#{self.id}:topic_read:#{topic.id}") == last_reply_id
  end

  # 将 topic 的最后回复设置为已读
  def read_topic(topic)
    # 处理 last_reply_id 是空的情况
    last_reply_id = topic.last_reply_id || -1
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
  
  # 软删除
  # 只是把用户信息修改了
  def soft_delete
    # assuming you have deleted_at column added already
    self.email = "#{self.login}_#{self.id}@ruby-china.org"
    self.login = "Guest"
    self.bio = ""
    self.website = ""
    self.github = ""
    self.tagline = ""
    self.location = ""
    self.state = STATE[:deleted]
    self.save(:validate => false)
  end

end
