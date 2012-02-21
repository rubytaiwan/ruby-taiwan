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
