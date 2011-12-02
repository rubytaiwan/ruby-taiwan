# coding: utf-8
class GikisController < ApplicationController
   
   def index
    @wiki = Wiki.find('Home')
    if @wiki
      @page_title = @wiki.title
      set_seo_meta("Wiki")
      drop_breadcrumb("Wiki", gikis_path)  
      drop_breadcrumb("Home")
      render :action => :show
    else
      @wiki = Wiki.new(:name => 'Home')
      @page_title = "Create New Page"
      render :new
    end
  end
  
  def show
    @wiki = Wiki.find(params[:id])
    unless @wiki
      @wiki = Wiki.new(:name => params[:id])
      @page_title = "Create New Page"
      drop_breadcrumb("Create New Page > #{@wiki.name}")
      render :new
      return
    end
    drop_breadcrumb("Wiki", gikis_path)  
    drop_breadcrumb(@wiki.name)  
  end
  
  def update
    @wiki =  Wiki.find(params[:id])
    
    commit = { :name => current_user.login, :email => current_user.email, :message => params[:wiki][:change_desc]}
    
    if @wiki.update_attributes(params[:wiki], commit)
      redirect_to giki_path(@wiki.name)
    else
      render :edit
    end
  end
  
  def create
    @wiki = Wiki.new(params[:wiki])
    commit = { :name => current_user.login, :email => current_user.email, :message => "Create #{@wiki.name}"}
    
    begin
      @wiki.save(commit)
      redirect_to giki_path(@wiki.name)
    rescue Gollum::DuplicatePageError => e
      render :text => "Duplicate page: #{e.message}"
    end
  end
  
  def new
    @data = Wiki.new(:name => params[:id])
    drop_breadcrumb("Wiki", gikis_path)  
    drop_breadcrumb("New Page")
  end
  
  def edit
    @wiki =  Wiki.find(params[:id])
    drop_breadcrumb("Wiki", gikis_path)  
    drop_breadcrumb("Edit > #{@wiki.name}")  
  end
  
end
