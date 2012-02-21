# coding: utf-8  
class Mongodb::User
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel

  store_in :users

  field :login
  field :email
  field :location
  field :bio
  field :website
  field :github
  # 是否信任用户
  field :verified, :type => Boolean, :default => true
  field :state, :type => Integer, :default => 1
  field :guest, :type => Boolean, :default => false
  field :tagline  
  field :topics_count, :type => Integer, :default => 0
  field :replies_count, :type => Integer, :default => 0  
  field :likes_count, :type => Integer, :default => 0
  
  index :login
  index :email
  index :location

  has_many :topics, :class_name => "Mongodb::Topic", :dependent => :destroy  
  has_many :notes, :class_name => "Mongodb::Note"
  has_many :replies, :class_name => "Mongodb::Reply", :dependent => :destroy
  embeds_many :authorizations, :class_name => "Mongodb::Authorization"
  has_many :posts, :class_name => "Mongodb::Post"
  has_many :notifications, :class_name => 'Mongodb::Notification::Base', :dependent => :delete
  has_many :photos, :class_name => "Mongodb::Photo"
  has_many :likes, :class_name => "Mongodb::Like"

  attr_accessor :password_confirmation
  attr_protected :verified, :replies_count
  
  validates :login, :format => {:with => /\A\w+\z/, :message => '只允许数字、大小写字母和下划线'}, :length => {:in => 3..20}, :presence => true, :uniqueness => {:case_sensitive => false}
  
  has_and_belongs_to_many :following_nodes, :class_name => 'Node', :inverse_of => :followers
  has_and_belongs_to_many :following, :class_name => 'User', :inverse_of => :followers
  has_and_belongs_to_many :followers, :class_name => 'User', :inverse_of => :following

  scope :hot, desc(:replies_count, :topics_count)

  STATE = {
    # 软删除
    :deleted => -1,
    # 正常
    :normal => 1,
    # 屏蔽
    :blocked => 2,
    
  }

end
