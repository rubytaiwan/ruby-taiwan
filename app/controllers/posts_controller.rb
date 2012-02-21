# coding: utf-8
class PostsController < ApplicationController
  before_filter :require_user, :only => [:new, :edit, :create, :update, :destroy]
  before_filter :set_menu_active
  after_filter :add_visit, :only => [:show]

  def index
    @posts = Post.normal.recent.paginate :page => params[:page], :per_page => 20
    set_seo_meta("文章")
    
    drop_breadcrumb("文章")
    drop_breadcrumb t("posts.recent_publish_post")
  end

  def tag_index
    tag_name = params[:tag_name]
    @posts = Post.normal.tagged_with(tag_name).recent.paginate(:page => params[:page], :per_page => 20)
    set_seo_meta("文章 - ##{tag_name}")

    drop_breadcrumb("文章")
    drop_breadcrumb("##{tag_name}")

    render :action => "index"
  end

  def show
    @post = Post.find(params[:id])
    set_seo_meta("#{@post.title}")
    drop_breadcrumb("文章")
    drop_breadcrumb t("common.read")
  end

  def new
    @post = Post.new
  end

  def edit
    @post = Post.find(params[:id])
    drop_breadcrumb("文章")
    drop_breadcrumb t("common.edit")
  end

  def create
    @post = current_user.posts.build(params[:post])
    
    if @post.save
      redirect_to @post, notice: t("posts.submit_success")
    else
      render action: "new"
    end
  end

  def update
    @post = current_user.posts.find(params[:id])
    
    if @post.update_attributes(params[:post])
      redirect_to @post, notice: '文章更新成功。'
    else
      render action: "edit"
    end
  end
  
  protected
  
  def set_menu_active
    @current = @current = ['/posts']
  end

  def add_visit
    @post.visit
  end
end
