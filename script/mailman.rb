#!/usr/bin/env ruby
require 'rubygems'
require 'bundler/setup'

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

Mailman::Application.run do
 to('notification+%reply_id%-%key%@ruby-hk.org') do |reply_id, key|
   puts "user:        #{params[:user]}"
   puts "reply_id:    #{reply_id}"
   puts "key:         #{key}"
   puts "message:     #{message}"
   puts "message_id:  #{message.message_id}"

 end
end
