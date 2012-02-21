class Notification::Base < ActiveRecord::Base

  self.table_name = "notifications"

  scope :recent, order("id DESC")
  scope :unread, where(:is_read => false)

  # source could be reply, topic or something else
  belongs_to :source, :polymorphic => true

  belongs_to :user

  def self.for_user(user)
    where(:user => user)
  end

  def anchor
    "notification-#{id}"
  end

  def self.mark_all_as_read!
    update_all(:is_read => true)
  end
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

