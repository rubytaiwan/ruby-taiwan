RubyChina::Application.routes.draw do
  resources :sites

  resources :posts do
    collection do
      match "tag/:tag_name" => "posts#tag_index", :via => :get, :as => :tagged
    end
  end

  resources :gikis, :path => "wiki" do 
    member do 
      get :history
    end
    
    collection do 
      get :list
      post :preview
    end
  end
  
  resources :comments
  resources :notes
  match "/uploads/*path" => "gridfs#serve"
  root :to => "home#index"  
 

  devise_for :users, :path => "account", :controllers => { 
      :registrations => :account,
      :omniauth_callbacks => "users/omniauth_callbacks" 
    }
  
  match "account/auth/:provider/unbind", :to => "users#auth_unbind"
  
  match "users/location/:id", :to => "users#location", :as => :location_users
  resources :users do
    member do 
      get :replies
      get :likes
      get :notes
    end 
  end
  resources :notifications, :only => [:index, :destroy] do
    collection do
      put :mark_all_as_read
    end
  end
  
  resources :nodes
  
  match "topics/node:id" => "topics#node", :as => :node_topics
  match "topics/node:id/feed" => "topics#node_feed", :as => :feed_node_topics
  match "topics/last" => "topics#recent", :as => :recent_topics
  resources :topics do
    member do
      post :reply
    end
    collection do
      get :search
      get :feed
      post :preview
    end
    resources :replies
  end

  resources :photos do
    collection do
      get :tiny_new
    end
  end
  resources :likes

  match "/search" => "search#index", :as => :search
  match "/search/topics" => "search#topics", :as => :search_topics
  match "/search/wiki" => "search#wiki", :as => :search_wiki

  namespace :cpanel do 
    root :to => "home#index"
    resources :site_configs
    resources :replies
    resources :topics do
      member do
        post :suggest
        post :unsuggest
        post :undestroy
      end
    end
    resources :nodes
    resources :sections
    resources :users do
      member do
        post :block
        post :unblock
        post :restore # from deleted state
      end
    end
    resources :photos
    resources :posts
    resources :comments
    resources :site_nodes
    resources :sites
  end  
  
  if Rails.env.development?
    mount UserMailer::Preview => 'mails/user'
  end
end
