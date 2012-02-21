require 'spec_helper'

describe Like do
  let(:topic) { Factory :topic }
  let(:user)  { Factory :user }
  let(:user2)  { Factory :user }

  describe "like topic" do
    after do
      Like.delete_all
    end
    
    it "can like/unlike topic" do
      user.like(topic)
      user.likes.count.should == 1
      user.reload
      user.likes_count.should == 1
      topic.reload
      topic.likes_count.should == 1
      user2.like(topic)
      topic.reload
      topic.likes_count.should == 2
      user2.unlike(topic)
      topic.reload
      user2.likes.count.should == 0
      user2.reload
      user2.likes_count.should == 0
      topic.likes_count.should == 1
    end
  end
end

# == Schema Information
#
# Table name: likes
#
#  id            :integer(4)      not null, primary key
#  likeable_id   :integer(4)
#  likeable_type :string(255)
#  user_id       :integer(4)
#  created_at    :datetime        not null
#  updated_at    :datetime        not null
#

