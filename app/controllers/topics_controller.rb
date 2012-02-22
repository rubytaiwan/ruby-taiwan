# coding: utf-8  
class TopicsController < ApplicationController
  
  load_and_authorize_resource :only => [:new,:edit,:create,:update,:destroy]
  
  before_filter :set_menu_active
  caches_page :feed, :node_feed, :expires_in => 1.hours
  before_filter :init_base_breadcrumb

  after_filter :add_visit, :only => [:show]

  def index
    @topics = Topic.last_actived.limit(15).includes(:node,:user).paginate(:page => params[:page], :per_page => 15)
    set_seo_meta("","#{Setting.app_name}#{t("menu.topics")}")
    drop_breadcrumb(t("topics.hot_topic"))
  end
  
  
  def node
    @node = Node.find(params[:id])
    @topics = @node.topics.last_actived.paginate(:page => params[:page],:per_page => 50)
    set_seo_meta("#{@node.name} &raquo; #{t("menu.topics")}","#{Setting.app_name}#{t("menu.topics")}#{@node.name}",@node.summary)
    drop_breadcrumb("#{@node.name}")
  end

  
  def recent
    # TODO: 需要 includes :node,:user,但目前用了 paginate 似乎会使得 includes 没有效果
    @topics = Topic.recent.paginate(:page => params[:page], :per_page => 50)
    drop_breadcrumb(t("topics.topic_list"))
  end
  

  def feed
    @topics = Topic.recent.limit(20).includes(:node,:user)
    response.headers['Content-Type'] = 'application/rss+xml'
    render :layout => false
  end

  
  def node_feed
    @node = Node.find(params[:id])
    @topics = @node.topics.recent.limit(20)
    response.headers["Content-Type"] = "application/rss+xml"
    render :layout => false
  end

  def node_feed
    @node = Node.find(params[:id])
    @topics = @node.topics.recent.limit(20)
    response.headers["Content-Type"] = "application/rss+xml"
    render :layout => false
  end

  def show
    @topic = Topic.includes(:user, :node).find(params[:id])
    @node = @topic.node
    @replies = @topic.replies.includes(:user)
    if current_user
      current_user.read_topic(@topic)

      # Mark all notifications from replies in this topic as read
      current_user.notifications.where(:source_id => @replies.map(&:id), :source_type => "Reply").mark_all_as_read!
    end
    set_seo_meta("#{@topic.title} &raquo; #{t("menu.topics")}")
    drop_breadcrumb("#{@node.name}", node_topics_path(@node.id))
    drop_breadcrumb t("topics.read_topic")
  end

  def new
    @topic = Topic.new
    if !params[:node].blank?
      @topic.node_id = params[:node]
      @node = Node.find_by_id(params[:node])
      if @node.blank?
        render_404
      end
      drop_breadcrumb("#{@node.name}", node_topics_path(@node.id))
    end
    drop_breadcrumb t("topics.post_topic")
    set_seo_meta("#{t("topics.post_topic")} &raquo; #{t("menu.topics")}")
  end

  def edit
    @topic = current_user.topics.find(params[:id])
    @node = @topic.node
    drop_breadcrumb("#{@node.name}", node_topics_path(@node.id))
    drop_breadcrumb t("topics.edit_topic")
    set_seo_meta("#{t("topics.edit_topic")} &raquo; #{t("menu.topics")}")
  end

  def create
    pt = params[:topic]
    @topic = Topic.new(pt)
    @topic.user_id = current_user.id
    @topic.node_id = params[:node] || pt[:node_id]

    if @topic.save
      redirect_to(topic_path(@topic.id), :notice => t("topics.create_topic_success"))
    else
      render :action => "new"
    end
  end

  def preview
    @body = params[:body]

    respond_to do |format|
      format.json
    end
  end

  def update
    @topic = current_user.topics.find(params[:id])
    pt = params[:topic]
    @topic.node_id = pt[:node_id]
    @topic.title = pt[:title]
    @topic.body = pt[:body]

    if @topic.save
      redirect_to(topic_path(@topic.id), :notice =>  t("topics.update_topic_success"))
    else
      render :action => "edit"
    end
  end

  def destroy
    @topic = current_user.topics.find(params[:id])
    @topic.destroy
    redirect_to(topics_path, :notice => t("topics.delete_topic_success"))
  end

  protected
  
  def set_menu_active
    @current = @current = ['/topics']
  end
  
  def init_base_breadcrumb
    drop_breadcrumb(t("menu.topics"), topics_path)
  end
  
  private
  
  def init_list_sidebar 
   if !fragment_exist? "topic/init_list_sidebar/hot_nodes"
      @hot_nodes = Node.hots.limit(10)
    end
    set_seo_meta(t("menu.topics"))
  end

  def add_visit
    @topic.visit
  end
end
