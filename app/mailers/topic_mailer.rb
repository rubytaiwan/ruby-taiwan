# encoding: utf-8
require 'digest/sha2'

class TopicMailer < BaseMailer
  layout 'reply_mailer'

  def notify_reply(recipient_id, topic_id, reply_id)
    @topic = Topic.find(topic_id)
    @reply = Reply.find(reply_id)
    @recipient = User.find(recipient_id)
    @reply_author = @reply.user

    # generate a reply key for this email, so that we can identify user
    @reply_key = TopicMailer.reply_key(@reply.email_key, @recipient.email)
    @reply_to = Setting.email_sender.gsub(/@/, "+#{reply_id}-#{@reply_key}@")

    mail(:to => @recipient.email, :subject => "[#{Setting.app_name}] 主題回覆通知： #{@topic.title}", :reply_to => @reply_to)
  end
  
  def self.reply_key(email_key, email)
    Digest::SHA2.hexdigest("#{email_key}-#{email}")
  end
end
