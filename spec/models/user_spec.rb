require 'spec_helper'

describe User do
  let(:topic) { Factory :topic }
  let(:user)  { Factory :user }
  let(:user2)  { Factory :user }
  let(:reply) { Factory :reply }
  let(:user_for_delete1) { Factory :user }
  let(:user_for_delete2) { Factory :user }

  describe '#read_topic?' do
    before do
      Rails.cache.write("user:#{user.id}:topic_read:#{topic.id}", nil)
    end
    
    it 'marks the topic as unread' do
      user.topic_read?(topic).should == false
      user.read_topic(topic)
      user.topic_read?(topic).should == true
      user2.topic_read?(topic).should == false
    end
    
    it "marks the topic as unread when got new reply" do
      topic.replies << reply
      user.topic_read?(topic).should == false
      user.read_topic(topic)
      user.topic_read?(topic).should == true
    end
    
    it "user can soft_delete" do
      user_for_delete1.soft_delete
      user_for_delete1.reload
      user_for_delete1.login.should == "Guest"
      user_for_delete1.state.should == -1
      user_for_delete2.soft_delete
      user_for_delete1.reload
      user_for_delete1.login.should == "Guest"
      user_for_delete1.state.should == -1
    end

    it "should not get results when user location not set" do
      User.locations.count == 0
    end

    it "should get results when user location is set" do
      user.location = "hangzhou"
      user2.location = "Hongkong"
      User.locations.count == 2
    end
  end
end

# == Schema Information
#
# Table name: users
#
#  id                   :integer(4)      not null, primary key
#  login                :string(255)     not null
#  location             :string(255)
#  tagline              :string(255)
#  bio                  :text
#  website              :string(255)
#  github               :string(255)
#  verified             :boolean(1)      default(TRUE)
#  guest                :boolean(1)      default(FALSE)
#  topics_count         :integer(4)      default(0)
#  replies_count        :integer(4)      default(0)
#  likes_count          :integer(4)      default(0)
#  created_at           :datetime        not null
#  updated_at           :datetime        not null
#  email                :string(255)     default(""), not null
#  encrypted_password   :string(128)     default(""), not null
#  reset_password_token :string(255)
#  remember_token       :string(255)
#  remember_created_at  :datetime
#  sign_in_count        :integer(4)      default(0)
#  current_sign_in_at   :datetime
#  last_sign_in_at      :datetime
#  current_sign_in_ip   :string(255)
#  last_sign_in_ip      :string(255)
#  state                :string(255)     default("normal")
#

