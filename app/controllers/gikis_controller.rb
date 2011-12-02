# coding: utf-8
class GikisController < ApplicationController
 
   def index
    @wiki = Wiki.find('Home')
    if @wiki
      @page_title = @wiki.title
      set_seo_meta("Wiki")
      drop_breadcrumb(@page_title)
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
    unless @data
      @wiki = Wiki.new(:name => params[:id])
      @page_title = "Create New Page"
      render :new
    else
      @page_title = @data.title
    end
  end
  
  def update
    @wiki =  Wiki.find(params[:id])
    if @wiki.update_attributes(params[:wiki])
      redirect_to giki_path(@wiki.name)
    else
      render :edit
    end
  end
  
  def create
    @wiki = Wiki.new(params[:wiki])
    begin
      @wiki.save
      redirect_to giki_path(@wiki.name)
    rescue Gollum::DuplicatePageError => e
      render :text => "Duplicate page: #{e.message}"
    end
  end
  
  def new
    @data = Wiki.new(:name => params[:id])
  end
  
  def edit
    @wiki =  Wiki.find(params[:id])
  end
  
end
