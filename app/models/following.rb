class Following < ActiveRecord::Base
  belongs_to :followable, :polymorphic => true
  belongs_to :user
end

# == Schema Information
#
# Table name: followings
#
#  id              :integer(4)      not null, primary key
#  followable_id   :integer(4)
#  followable_type :string(255)
#  user_id         :integer(4)
#  created_at      :datetime        not null
#  updated_at      :datetime        not null
#

