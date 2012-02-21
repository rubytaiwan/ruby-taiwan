# coding: utf-8
# 喜欢
# 多态设计，可以用于收藏 Topic, Post ...
class Like < ActiveRecord::Base
  belongs_to :likeable, :polymorphic => true, :counter_cache => true
  belongs_to :user

  scope :recent, order("id DESC")
  scope :topics, where(:likeable_type => 'Topic')
end
# == Schema Information
#
# Table name: likes
#
#  id            :integer(4)      not null, primary key
#  likeable_id   :integer(4)
#  likeable_type :string(255)
#  user_id       :integer(4)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

