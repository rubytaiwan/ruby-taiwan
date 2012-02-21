class Notification::General < Notification::Base
end

# == Schema Information
#
# Table name: notifications
#
#  id          :integer(4)      not null, primary key
#  type        :string(255)     not null
#  source_id   :integer(4)
#  source_type :string(255)
#  user_id     :integer(4)
#  is_read     :boolean(1)      default(FALSE)
#  created_at  :datetime        not null
#  updated_at  :datetime        not null
#

