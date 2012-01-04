source 'http://rubygems.org'

gem "rails", "3.1.3"
gem "bson_ext", "1.5.2"
gem "mongoid", "2.3.4"

# 上传组件
gem 'carrierwave', '0.5.6'
gem 'carrierwave-mongoid', '0.1.2', :require => 'carrierwave/mongoid'
# 图像处理
gem 'mini_magick','3.3'
# Mongoid 辅助插件
gem 'mongo-rails-instrumentation','0.2.4'
# Mongoid 使用自增整形ID
gem 'mongoid_auto_increment_id', "0.3.1"

# 用户系统
gem 'devise', '1.5.2'
# 分页

gem 'will_paginate', '3.0.pre4'

# 三方平台 OAuth 验证登陆

gem "mongoid_search"
gem "omniauth"
gem 'omniauth-openid'
gem "omniauth-github"
gem "omniauth-twitter"
gem "omniauth-douban", :git => "git://github.com/ballantyne/omniauth-douban.git"

# permission
gem "cancan"

# 搜索相关的组件
gem 'chinese_pinyin', '0.4.1'
gem "rmmseg-cpp-huacnlee", "0.2.8"
gem 'redis-search', '0.6.3'
# Rails I18n
gem "rails-i18n","0.1.8"
# Redis 命名空间
gem 'redis-namespace','~> 1.0.2'
# 将一些数据存放入 Redis
gem "redis-objects", "0.5.2"
# Markdown 格式
gem "redcarpet", "~> 2.0.0"
gem "pygments.rb"
# HTML 处理
gem "nokogiri", "1.5.0"
gem "hpricot"
gem "jquery-rails", "1.0.16"
# Auto link
gem "rails_autolink", ">= 1.0.4"
# YAML 配置信息
gem "settingslogic", "~> 2.0.6"
gem "cells", "3.6.7"
gem "resque", "~> 1.19.0", :require => "resque/server"
gem "resque_mailer", '2.0.2'
gem "aws-ses", "~> 0.4.3"
gem 'mail_view', :git => 'git://github.com/37signals/mail_view.git'
gem "daemon-spawn", "~> 0.4.2"
gem "unicorn"


# for opengraph

gem 'open_graph_helper'

# for wiki
gem 'grit', :git => "git://github.com/mojombo/grit.git"
gem 'gollum', :require => "gollum", :git => "git://github.com/xdite/gollum.git"

# 用于组合小图片

# https://github.com/thetron/css3buttons_rails_helpers/pull/24
gem 'css3buttons', :git => "git://github.com/thetron/css3buttons_rails_helpers.git"

gem "sprite-factory", "1.4.1"

gem "social-share-button", "~> 0.0.1"
gem "open_graph_helper"
# Simple form last commit: 2011-12-03 
gem 'simple_form', :git => "git://github.com/plataformatec/simple_form.git"
gem 'anjlab-bootstrap-rails', :git => "git://github.com/anjlab/bootstrap-rails.git", :require => "bootstrap-rails"
gem 'bootstrap_helper', "1.4.1"
gem "airbrake"
gem 'newrelic_rpm'


group :assets do
  gem 'sass-rails', "  ~> 3.1.4"
  gem 'coffee-rails', "~> 3.1.1"
  gem 'uglifier'
end

group :mailman do
  gem "rb-inotify"
  gem "mailman"
  gem "nokogiri", "1.5.0"
  gem "daemon-spawn", "~> 0.4.2"
  gem "resque", "~> 1.19.0", :require => "resque/server"
end

group :development do
  gem 'capistrano', '2.9.0'
  gem 'chunky_png', "1.2.5"
  gem "memcache-client", "1.8.5"
end

group :development, :test do
  gem 'rspec-rails', '~> 2.7.0'
end

group :test do
  gem 'factory_girl_rails'
end

group :production do
  gem 'dalli', '1.1.1'
end
