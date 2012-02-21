require 'spec_helper'

describe Following do
  pending "add some examples to (or delete) #{__FILE__}"
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

