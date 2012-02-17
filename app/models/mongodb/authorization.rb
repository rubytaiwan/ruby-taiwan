# coding: utf-8
class Mongodb::Authorization

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::BaseModel
  store_in :authorizations

  field :provider
  field :uid
  embedded_in :user, :inverse_of => :authorizations, :class_name => "Mongodb::User"
    
end

