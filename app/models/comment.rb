# coding: utf-8
class Comment < ActiveRecord::Base
  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :user
  validates_presence_of :body

  scope :recent, order("id DESC")
end
