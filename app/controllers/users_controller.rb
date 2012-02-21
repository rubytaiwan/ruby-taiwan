# coding: utf-8  
class UsersController < ApplicationController
  before_filter :require_user, :only => "auth_unbind"
  before_filter :init_base_breadcrumb
  before_filter :set_menu_active
  load_and_authorize_resource :find_by => :login,
                              :except => [:auth_unbind, :location]
  skip_authorize_resource :only => :index

  def index
    @total_user_count = User.count
    drop_breadcrumb t("common.index")
  end
  
  def show
    @topics = @user.topics.recent.paginate(:page => params[:page], :per_page => 20)          
    set_seo_meta("#{@user.login}")
    drop_breadcrumb(@user.login)
  end
  
  def replies
    @replies = @user.replies.recent.includes(:topic).limit(10)
    drop_breadcrumb(@user.login, user_path(@user.login))
    drop_breadcrumb("回帖")
  end
  
  def likes
    @likes = @user.likes.recent.topics.paginate(:page => params[:page], :per_page => 20)
    drop_breadcrumb(@user.login, user_path(@user.login))
    drop_breadcrumb("喜欢")
  end

  def notes
    @notes = @user.notes.public.paginate(:page => params[:page], :per_page => 20)
    drop_breadcrumb(@user.login, user_path(@user.login))
    drop_breadcrumb("公開記事")
  end
  
  def auth_unbind
    provider = params[:provider]
    if current_user.authorizations.count <= 1
      redirect_to edit_user_registration_path, :flash => {:error => t("users.unbind_warning")}
      return
    end
    
    current_user.authorizations.destroy_all(:conditions => {:provider => provider})
    redirect_to edit_user_registration_path, :flash => {:warring => t("users.unbind_success", :provider => provider.titleize )}
  end
  
  def location
    @location = params[:id]
    @users = User.where(:location => @location).order("replies_count DESC").paginate(:page => params[:page], :per_page => 30)
    if @users.count == 0
      render_404
    end
    drop_breadcrumb(@location)
  end
  
  protected
  
  def set_menu_active
    @current = @current = ['/users']
  end
  
  def init_base_breadcrumb
    drop_breadcrumb( t("menu.users"), users_path)
  end
  
end
