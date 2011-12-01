class ReplyMailing
  @queue = :normal 
  def self.perform(reply_id)
    @reply = Reply.find(reply_id)
    @reply.send_notify_reply_mail
  end
end