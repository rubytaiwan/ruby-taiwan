# coding: utf-8
class Authorization < ActiveRecord::Base
  belongs_to :user, :inverse_of => :authorizations
  validates_presence_of :uid, :provider
  validates_uniqueness_of :uid, :scope => :provider
end

