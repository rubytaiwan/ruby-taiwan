# coding: utf-8  
class Cpanel::TopicsController < Cpanel::ApplicationController

  def index
    @topics = Topic.unscoped.order("id DESC").includes(:user).paginate :page => params[:page], :per_page => 30

  end

  def show
    @topic = Topic.unscoped.find(params[:id])

  end


  def new
    @topic = Topic.new
  end

  def edit
    @topic = Topic.unscoped.find(params[:id])
  end

  def create
    @topic = Topic.new(params[:topic])

    if @topic.save
      redirect_to(cpanel_topics_path, :notice => 'Topic was successfully created.')
    else
      render :action => "new" 
    end
  end

  def update
    @topic = Topic.unscoped.find(params[:id])

    if @topic.update_attributes(params[:topic])
      redirect_to(cpanel_topics_path, :notice => 'Topic was successfully updated.')
    else
      render :action => "edit" 
    end
  end

  def destroy
    @topic = Topic.unscoped.find(params[:id])
    @topic.destroy

    redirect_to(cpanel_topics_path)
  end
  
  def undestroy
    @topic = Topic::Archived.unscoped.find(params[:id])
    @topic.destroy # restore to Topic
    redirect_to(cpanel_topics_path)
  end
  
  def suggest
    @topic = Topic.unscoped.find(params[:id])
    @topic.update_attribute(:suggested_at, Time.now)
    CacheVersion.topic_last_suggested_at = Time.now
    redirect_to(cpanel_topics_path, :notice => "Topic:#{params[:id]} suggested.")
  end
  
  def unsuggest
    @topic = Topic.unscoped.find(params[:id])
    @topic.update_attribute(:suggested_at, nil)
    CacheVersion.topic_last_suggested_at = Time.now
    redirect_to(cpanel_topics_path, :notice => "Topic:#{params[:id]} unsuggested.")
  end
end
