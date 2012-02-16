class Mongodb::Notification::Base
  include Mongoid::Document
  include Mongoid::Timestamps::Created
  include Mongoid::BaseModel

  store_in :notifications

  field :read, :default => false

  belongs_to :user, :class_name => "Mongodb::User"

  index [[:user_id, Mongo::ASCENDING], [:read, Mongo::ASCENDING]]

end
