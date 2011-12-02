#!/usr/bin/env ruby
require 'rubygems'
require 'mailman'
require 'resque'

env = ENV['RAILS_ENV'] || 'development'
config = YAML::load(open("./config/mailer_daemon.yml"))[env]
Mailman.config.pop3 = {
  :username => config["username"],
  :password => config["password"],
  :server   => config["server"],
  :port     => config["port"],
  :ssl      => config["ssl"]
}

def plaintext_body(message)
  if message.multipart?
    message.parts.each do |p|
      if p.content_type =~ /text\/plain/
        encoding = p.content_type.to_s.split("=").last.to_s
        return safe_str_encoding(p.body,encoding)
      end
    end
    raise "mail body multipart, but not text/plain part"
  elsif message.content_type == 'text/plain'
    return safe_str_encoding(message.body, message.encoding)
  else
    raise "mail body is not multipart nor text/plain"     
  end
end

def safe_str_encoding(html, coding)
  doc = Nokogiri::HTML(html.to_s, nil, coding)
  return doc.css("body").text
end

Mailman::Application.run do
 to('notification+%reply_id%-%key%@ruby-hk.org') do |reply_id, key|
   puts "from:        #{message.from.first}"
   puts "reply_id:    #{reply_id}"
   puts "key:         #{key}"
   puts "message_id:  #{message.message_id}"
   puts "body:  #{plaintext_body(message)}"
   
 end
end
