# coding: utf-8
class SearchController < ApplicationController
  
  before_filter :validate_search_key
   def index
     if @query_string.present?
       @topics = Topic.search(@query_string).paginate(:page => params[:page], :per_page => 20)
     end
     @current = ["/search/topics?q=#{params[:q]}"]
     
     render :action => "topics"
     
     set_seo_meta("#{t("common.search")}: #{@query_string}")
     drop_breadcrumb("#{t("common.search")}: #{@query_string}")
  end

  def topics
    
    if @query_string.present?
      @topics = Topic.search(@query_string).paginate(:page => params[:page], :per_page => 20)
    end
    
    set_seo_meta("#{t("common.search")}: #{@query_string}")
    drop_breadcrumb("#{t("common.search")}: #{@query_string}")

   end

  def wiki
    if @query_string.present?
      @results = Wiki.search(@query_string)
    end
    
    set_seo_meta("#{t("common.search")}: #{@query_string}")
    drop_breadcrumb("#{t("common.search")}: #{@query_string}")
  end

  protected

    def validate_search_key
      @query_string = params[:q].gsub(/\\|\'|-|\/|\.|\?/, "") if params[:q].present?
    end
end
