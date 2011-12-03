# reply email and create topic as needed

class ReplyListener
  @queue = :mailer

  def self.perform(reply_id, key, message_id, from_email, reply_text)
    previous_reply    = Reply.find(reply_id)
    reply_user        = User.find_by_email(from_email)

    valid_reply_key   = TopicMailer.reply_key(previous_reply.email_key, reply_user.email)
    if valid_reply_key != key
      raise "Invalid reply: #{reply_id}, key: #{key}, from: #{from}"
    end

    reply             = Reply.new
    reply.topic_id    = previous_reply.topic_id
    reply.user_id     = reply_user.id
    reply.body        = reply_text
    reply.source      = 'mail'
    reply.message_id  = message_id
    reply.save!
  end
end