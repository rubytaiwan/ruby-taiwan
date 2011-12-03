require 'nokogiri'

module MailHelper

  # find the email body in a message
  def plaintext_body(message)
    if message.multipart?
      message.parts.each do |p|
        if p.content_type =~ /text\/plain/
          encoding = p.content_type.to_s.split("=").last.to_s
          return extract_content(p.body,encoding)
        end
      end
      raise "mail body multipart, but not text/plain part"
    elsif message.content_type == 'text/plain'
      return extract_content(message.body, message.encoding)
    else
      raise "mail body is not multipart nor text/plain"     
    end
  end

  # extract email content from a body
  # use the sender email line as separation
  def extract_reply(body, sender_email)
    body.strip
      .gsub(/\n^[^\r\n]*#{sender_email}.*:.*\z/m, '')
      .strip
  end
  
  private
  def extract_content(html, coding)
    doc = Nokogiri::HTML(html.to_s, nil, coding)
    return doc.css("body").text
  end
end
