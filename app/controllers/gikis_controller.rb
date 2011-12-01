class GikisController < ApplicationController
  
  def index
    @data = Wiki.find('Home')
    if @data
      @page_title = @data.title
      render :action => :show
    else
      @wiki = Wiki.new(:name => params[:page_name])
      @page_title = "Create New Page"
      render :new, :layout => "editor"
    end
  end
  
  def show
    
    unless @data
      @wiki = Wiki.new(:name => params[:page_name])
      @page_title = "Create New Page"
      render :new, :layout => "editor"
    else
      @page_title = @data.title
    end
  end
  
end
