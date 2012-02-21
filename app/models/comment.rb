# coding: utf-8
class Comment < ActiveRecord::Base
  acts_as_archive

  belongs_to :commentable, :polymorphic => true, :counter_cache => true
  belongs_to :user, :inverse_of => :comments
  validates_presence_of :body

  scope :recent, order("id DESC")
end

# == Schema Information
#
# Table name: comments
#
#  id               :integer(4)      not null, primary key
#  body             :text
#  user_id          :integer(4)
#  commentable_id   :integer(4)
#  commentable_type :string(255)
#  created_at       :datetime        not null
#  updated_at       :datetime        not null
#

