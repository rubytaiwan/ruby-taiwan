source "http://rubygems.org"

gem "rails", "3.2.1"
gem "mysql2"

# 上传组件
gem "carrierwave", "0.5.6"
# 图像处理
gem "mini_magick","3.3"

# 用户系统
gem "devise", "1.5.2"
# 分页

gem "will_paginate", "~> 3.0"

# 三方平台 OAuth 验证登陆

gem "omniauth", "~> 1.0.1"
gem "omniauth-openid", "~> 1.0.1"
gem "omniauth-github", "~> 1.0.0"
gem "omniauth-twitter", "~> 0.0.7"
gem "omniauth-douban", :git => "git://github.com/ballantyne/omniauth-douban.git"

# permission
gem "cancan", "~> 1.6.7"



# 搜索相关的组件
gem "ransack"
# Rails I18n
gem "rails-i18n","0.1.8"
# Redis 命名空间
gem "redis-namespace","~> 1.0.2"
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
gem "cells", "3.7.1"
gem "resque", "~> 1.19.0", :require => "resque/server"
gem "resque_mailer", "2.0.2"
gem "aws-ses", "~> 0.4.3"
gem "mail_view", :git => "git://github.com/37signals/mail_view.git"
gem "daemon-spawn", "~> 0.4.2"
gem "unicorn"
# Tagging
gem "acts-as-taggable-on", "~> 2.2.2"
# Soft Delete
gem "acts_as_archive", :git => "git://github.com/stipple/acts_as_archive.git"
# Finite-State Machine
gem "state_machine"

# for opengraph

gem "open_graph_helper"

# for wiki
gem "grit", :git => "git://github.com/mojombo/grit.git"
gem "gollum", :require => "gollum", :git => "git://github.com/xdite/gollum.git"

# 用于组合小图片

# https://github.com/thetron/css3buttons_rails_helpers/pull/24
gem "css3buttons", :git => "git://github.com/thetron/css3buttons_rails_helpers.git"

gem "sprite-factory", "1.4.1"

gem "social-share-button", "~> 0.0.3"
gem "open_graph_helper"

# Simple form last commit: 2011-12-03 
gem "simple_form", :git => "git://github.com/plataformatec/simple_form.git"
gem "anjlab-bootstrap-rails", :git => "git://github.com/anjlab/bootstrap-rails.git", :require => "bootstrap-rails"
gem "bootstrap_helper", "1.4.1"
gem "airbrake"
gem "newrelic_rpm"


group :assets do
  gem "sass-rails", "  ~> 3.2.3"
  gem "coffee-rails", "~> 3.2.1"
  gem "uglifier", ">= 1.0.3"
end

group :mailman do
  gem "rb-inotify"
  gem "mailman"
  gem "nokogiri", "1.5.0"
  gem "daemon-spawn", "~> 0.4.2"
  gem "resque", "~> 1.19.0", :require => "resque/server"
end

group :development do
  gem "annotate"
  gem "capistrano", "2.9.0"
  gem "chunky_png", "1.2.5"
  gem "memcache-client", "1.8.5"
end

group :development, :test do
  gem "rspec-rails", "~> 2.8.1"
  gem "progress_bar"
  gem "quiet_assets", :git => "git://github.com/AgilionApps/quiet_assets.git"
end

group :test do
  gem "factory_girl_rails"
end

group :production do
  gem "dalli", "1.1.1"
end
