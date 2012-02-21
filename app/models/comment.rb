# coding: utf-8
class Comment < ActiveRecord::Base
  acts_as_archive

  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :user, :inverse_of => :comments
  validates_presence_of :body

  scope :recent, order("id DESC")
end
