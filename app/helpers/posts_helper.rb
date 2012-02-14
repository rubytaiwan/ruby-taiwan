# coding: utf-8  
module PostsHelper
  def post_title_tag(post, opts = {})
    return "" if post.blank?
    link_to(post.title, post_path(post), :title => post.title )
  end
  
  def post_tags_tag(post, opts = {})
    if post.present?
      post.tags.limit(5).collect { |tag|
        link_to("##{tag.name}", tagged_posts_path(tag.name))
      }.join(", ").html_safe
    end
  end
  
  def render_post_state_s(post)
    case post.state
    when 0 then content_tag(:span, "草稿", :class => "label important")
    else
      content_tag(:span, "已审核", :class => "label success" )
    end
  end
end
