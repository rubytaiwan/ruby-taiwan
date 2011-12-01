# encoding: utf-8
class TopicMailer < BaseMailer
  def notify_reply(recipient_id, topic_id, reply_id)
    @topic = Topic.find(topic_id)
    @reply = Reply.find(reply_id)
    @recipient = User.find(recipient_id)
    @reply_author = @reply.user

    mail(:to => @recipient.email, :subject => "[#{Setting.app_name}] 主題回覆通知： #{@topic.title}")
  end
end
