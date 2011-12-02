# reply email and create topic as needed

class ReplyListener
  def self.perform(reply_id, key, from, text, message_id)
    previous_reply    = Reply.find(reply_id)
    recipient         = User.find(from)

    valid_reply_key   = TopicMailer.reply_key(previous_reply.email_key, recipient.email)
    if valid_reply_key != key
      raise "Invalid reply: #{reply_id}, key: #{key}, from: #{from}"
    end

    reply             = previous_reply.topic.replies.build
    reply.body        = text
    reply.user_id     = reply_user.id
    reply.message_id  = message_id
    reply.save!
  end
end