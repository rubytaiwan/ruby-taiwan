# coding: utf-8
class RepliesController < ApplicationController
  before_filter :require_user
  before_filter :find_topic
  def create
    
    @reply = @topic.replies.build(params[:reply])   
         
    @reply.user_id = current_user.id
    if @reply.save
      current_user.read_topic(@topic)
      @msg = t("topics.reply_success")

      # HINT: In Reply model,
      #       there is an after_create hook :send_mention_notification
      #       to send notifications to users who are mentioned in this reply.

      # Hint: In Reply model, 
      #       there is an after_create hook :update_parent_topic
      #       to update the topic record that the new reply belongs to,
      #       in which updates topic's last update time, 
      #       the latest reply and its author,
      #       and adds the reply author to the followers list.

      send_notify_reply_mail(@topic, @reply, :exclude_mentioned => true)
    else
      @msg = @reply.errors.full_messages.join("<br />")
    end
  end
  
  def edit
    @reply = current_user.replies.find(params[:id])
    drop_breadcrumb(t("menu.topics"), topics_path)
    drop_breadcrumb t("reply.edit_reply")
  end
  
  def update
    @reply = current_user.replies.find(params[:id])

    if @reply.update_attributes(params[:reply])
      redirect_to(topic_path(@reply.topic_id), :notice => '回帖更新成功.')
    else
      render :action => "edit"
    end
  end
  
  protected
  
  def find_topic
    @topic = Topic.find(params[:topic_id])
  end

  def send_notify_reply_mail(topic, reply, options={})

    # set :exclude_mentioned to true to exclude mentioned users
    # from the reply notification mail recipients
    options[:exclude_mentioned] ||= false

    # fetch follower ids from the topic (may or may not include the topic author)
    recipient_ids = Set.new(topic.follower_ids)

    # don't send reply notification to the author of the reply
    recipient_ids.delete(reply.user.id)

    # prevent duplicated mail sent to users mentioned in the reply
    recipient_ids.subtract(reply.mentioned_user_ids) if options[:exclude_mentioned] == true

    # add the topic author to the recipients, if he is not the reply author
    recipient_ids.add(topic.user.id) if topic.user.id != reply.user.id

    # find recipient users
    recipients = User.find(recipient_ids.to_a)

    recipients.each do |recipient|
      next if recipient == nil
      TopicMailer.notify_reply(recipient, topic, reply).deliver
    end
  end
end