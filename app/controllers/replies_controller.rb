# coding: utf-8
class RepliesController < ApplicationController

  load_and_authorize_resource :reply

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

end