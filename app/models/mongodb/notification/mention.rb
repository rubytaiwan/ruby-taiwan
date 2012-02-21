class Mongodb::Notification::Mention < Notification::Base
  belongs_to :reply, :class_name => "Mongodb::Reply"
end
