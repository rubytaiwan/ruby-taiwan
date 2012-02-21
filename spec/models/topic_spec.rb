require 'spec_helper'

describe Topic do
  it "should set replied_at" do
    Factory(:topic).replied_at.should_not be_nil
  end

  it "should get node name" do
    node = Factory :node
    Factory(:topic, :node => node).node_name.should == node.name
  end

  it "should push and pull follower" do
    topic = Factory :topic
    user  = Factory :user
    topic.push_follower user.id
    topic.follower_ids.include?(user.id).should be_true
    topic.pull_follower user.id
    topic.follower_ids.include?(user.id).should_not be_true
  end

  it "should update after reply" do
    topic = Factory :topic
    reply = Factory :reply, :topic => topic
    topic.replied_at.should == reply.created_at
    topic.last_reply.id.should == reply.id
    topic.last_reply.user_id.should == reply.user_id
    topic.follower_ids.include?(reply.user_id).should be_true
  end
end

# == Schema Information
#
# Table name: topics
#
#  id            :integer(4)      not null, primary key
#  title         :string(255)     not null
#  body          :text            default(""), not null
#  source        :string(255)
#  node_id       :integer(4)
#  user_id       :integer(4)
#  message_id    :integer(4)
#  replies_count :integer(4)      default(0)
#  likes_count   :integer(4)      default(0)
#  visit_count   :integer(4)      default(0)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#  suggested_at  :datetime
#  replied_at    :datetime
#

