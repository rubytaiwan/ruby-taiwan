# coding: utf-8
class Authorization < ActiveRecord::Base
  belongs_to :user, :inverse_of => :authorizations
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
end


# == Schema Information
#
# Table name: authorizations
#
#  id         :integer(4)      not null, primary key
#  user_id    :integer(4)      not null
#  provider   :string(255)     not null
#  uid        :string(255)     not null
#  created_at :datetime        not null
#  updated_at :datetime        not null
#

