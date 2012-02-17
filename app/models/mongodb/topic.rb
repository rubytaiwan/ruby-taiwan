# coding: utf-8
class Mongodb::Topic

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  include Mongoid::CounterCache
  include Redis::Objects

  store_in :topics

  field :title
  field :body
  field :last_reply_id, :type => Integer
  field :replied_at , :type => DateTime
  field :source
  field :message_id
  field :replies_count, :type => Integer, :default => 0
  # 回复过的人的 ids 列表
  field :follower_ids, :type => Array, :default => []
  field :suggested_at, :type => DateTime
  field :likes_count, :type => Integer, :default => 0

  belongs_to :user, :class_name => "Mongodb::User", :inverse_of => :topics
  counter_cache :name => :user, :inverse_of => :topics
  belongs_to :node, :class_name => "Mongodb::Node"
  counter_cache :name => :node, :inverse_of => :topics
  belongs_to :last_reply_user, :class_name => 'Mongodb::User'
  has_many :replies, :class_name => "Mongodb::Reply", :dependent => :destroy

  index :node_id
  index :user_id
  index :replied_at
  index :suggested_at

  counter :hits, :default => 0
end
