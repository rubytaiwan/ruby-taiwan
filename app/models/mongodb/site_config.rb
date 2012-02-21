# coding: utf-8
# 在数据库中的配置信息
# 这里有存放首页,Wiki 等页面 HTML
# 使用方法
# SiteConfig.foo
# SiteConfig.foo = "asdkglaksdg"
class Mongodb::SiteConfig
  
  include Mongoid::Document
  store_in :site_configs
  
  field :key
  field :value
  
  index :key
end