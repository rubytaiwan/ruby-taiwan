# coding: utf-8
require "./config/boot"
require "bundler/capistrano"
require 'airbrake/capistrano'
default_environment["RAILS_ENV"] = "production"
default_environment["PATH"] = "/usr/local/bin:/usr/bin:/bin"

set :application, "ruby-taiwan"
set :repository,  "git://github.com/rubytaiwan/ruby-taiwan.git"

set :branch, "production"
set :scm, :git
set :user, "apps"
set :deploy_to, "/home/apps/#{application}"
set :runner, "apps"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1

role :web, "ruby-taiwan.org"                          # Your HTTP server, Apache/etc
role :app, "ruby-taiwan.org"                          # This may be the same as your `Web` server
role :db,  "ruby-taiwan.org", :primary => true # This is where Rails migrations will run

namespace :deploy do

  desc "Restart passenger process"
  task :restart, :roles => [:web], :except => { :no_release => true } do
    run "touch #{current_path}/tmp/restart.txt"
  end
end


namespace :my_tasks do
  task :symlink, :roles => [:web] do
    run "mkdir -p #{deploy_to}/shared/log"
    run "mkdir -p #{deploy_to}/shared/pids"
    
    symlink_hash = {
      "#{shared_path}/config/mongoid.yml"   => "#{release_path}/config/mongoid.yml",
      "#{shared_path}/config/config.yml"    => "#{release_path}/config/config.yml",
      "#{shared_path}/config/newrelic.yml"  => "#{release_path}/config/newrelic.yml",
      "#{shared_path}/config/redis.yml"     => "#{release_path}/config/redis.yml",
    }

    symlink_hash.each do |source, target|
      run "ln -sf #{source} #{target}"
    end
    run "ln -sf #{shared_path}/doc/wiki_repo #{release_path}/doc/wiki_repo"
  end
  
  task :restart_resque, :roles => :web do
    run "cd #{release_path}; RAILS_ENV=production ./script/resque stop; RAILS_ENV=production ./script/resque start"
  end
  
  task :mongoid_create_indexes, :roles => :web do
    run "cd #{release_path}; bundle exec rake db:mongoid:create_indexes"
  end
end



namespace :remote_rake do
  desc "Run a task on remote servers, ex: cap staging rake:invoke task=cache:clear"
  task :invoke do
    run "cd #{deploy_to}/current; RAILS_ENV=#{rails_env} bundle exec rake #{ENV['task']}"
  end
end

after "deploy:finalize_update", "my_tasks:symlink"
#after "deploy:finalize_update", "my_tasks:mongoid_create_indexes"
#after "deploy:restart", "my_tasks:restart_resque"

