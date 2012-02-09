# coding: utf-8  
# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
s1 = Section.create(:name => "Ruby")
Node.create(:name => "Ruby",:summary => "...", :section_id => s1.id)
Node.create(:name => "Ruby on Rails",:summary => "...", :section_id => s1.id)
Node.create(:name => "Gem",:summary => "...", :section_id => s1.id)
s2 = Section.create(:name => "Web Development")
Node.create(:name => "Python",:summary => "...", :section_id => s2.id)
Node.create(:name => "Javascript",:summary => "...", :section_id => s2.id)
Node.create(:name => "CoffeeScript",:summary => "...", :section_id => s2.id)
Node.create(:name => "HAML",:summary => "...", :section_id => s2.id)
Node.create(:name => "SASS",:summary => "...", :section_id => s2.id)
Node.create(:name => "MongoDB",:summary => "...", :section_id => s2.id)
Node.create(:name => "Redis",:summary => "...", :section_id => s2.id)
Node.create(:name => "Git",:summary => "...", :section_id => s2.id)
Node.create(:name => "MySQL",:summary => "...", :section_id => s2.id)
Node.create(:name => "Hadoop",:summary => "...", :section_id => s2.id)
Node.create(:name => "Google",:summary => "...", :section_id => s2.id)
Node.create(:name => "Java",:summary => "...", :section_id => s2.id)
Node.create(:name => "Tornado",:summary => "...", :section_id => s2.id)
Node.create(:name => "Linux",:summary => "...", :section_id => s2.id)
Node.create(:name => "Nginx",:summary => "...", :section_id => s2.id)
Node.create(:name => "Apache",:summary => "...", :section_id => s2.id)
Node.create(:name => "Cloud",:summary => "...", :section_id => s2.id)
s6 = Section.create(:name => "Ruby China")
Node.create(:name => "公告",:summary => "...", :section_id => s6.id)
Node.create(:name => "反馈",:summary => "...", :section_id => s6.id)
Node.create(:name => "开发",:summary => "...", :section_id => s6.id)

# 首页
# SiteConfig.index_html
SiteConfig.create(:key => "index_html",:value => <<-eos
<div class="box" style="text-align:center;">
  <p><img alt="Big_logo" src="/assets/big_logo.png"></p>
  <p></p>
  <p>Ruby China Group， 致力于构建完善的 Ruby 中文社区。</p>
  <p>功能正在完善中，欢迎 <a href="http://github.com/huacnlee/ruby-china">贡献代码</a> 。</p>
  <p>诚邀有激情的活跃 Ruby 爱好者参与维护社区，联系 <b style="color:#c00;">lgn21st@gmail.com</b></p>
</div>
eos
)

# Wiki 首页 HTML
SiteConfig.create(:key => "wiki_index_html",:value => <<-eos
<div class="box">
  Wiki Home page.
</div>
eos
)

# Footer HTML
SiteConfig.create(:key => "footer_html",:value => <<-eos
<p class="copyright">
 &copy; Ruby China Group. 
</p>
eos
)

# 话题后面的HTML代码
SiteConfig.create(:key => "after_topic_html",:value => <<-eos
<div class="share_links">
 <a href="https://twitter.com/share" class="twitter-share-button" data-count="none"">Tweet</a>
 <script type="text/javascript" src="//platform.twitter.com/widgets.js"></script>
</div>
eos
)

# 话题正文前面的HTML
SiteConfig.create(:key => "before_topic_html",:value => <<-eos
eos
)

# 话题列表首页边栏HTML
SiteConfig.create(:key => "topic_index_sidebar_html",:value => <<-eos
<div class="box">
  <h2>公告</h2>
  <div class="content">
    Hello world.
  </div>
</div>

<div class="box">
  <h2>置顶话题</h2>
  <ul class="content">
    <li><a href="/topics/1">Foo bar</a></li>
  </ul>
</div>
eos
)

# 酷站列表首页头的HTML
SiteConfig.create(:key => "site_index_html",:value => <<-eos
下面列出了基于 Ruby 语言开发的网站。如果你知道还有不在此列表的，请帮忙补充。
eos
)