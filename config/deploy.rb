# coding: utf-8
set :application, "ruby-china"
set :repository,  "git://github.com/huacnlee/ruby-china.git"
set :branch, "master"
set :scm, :git
set :user, "ruby"
set :deploy_to, "/home/#{user}/www/#{application}"
set :runner, "ruby"
set :deploy_via, :remote_cache
set :git_shallow_clone, 1

role :web, "58.215.172.218"                          # Your HTTP server, Apache/etc
role :app, "58.215.172.218"                          # This may be the same as your `Web` server
role :db,  "58.215.172.218", :primary => true # This is where Rails migrations will run

# unicorn.rb 路径
set :unicorn_path, "#{deploy_to}/current/config/unicorn.rb"

namespace :deploy do
  task :start, :roles => :app do
    run "cd #{deploy_to}/current/; RAILS_ENV=production unicorn_rails -c #{unicorn_path} -D"
  end

  task :stop, :roles => :app do
    run "kill -QUIT `cat #{deploy_to}/current/tmp/pids/unicorn.pid`"
  end

  desc "Restart Application"
  task :restart, :roles => :app do
    run "kill -USR2 `cat #{deploy_to}/current/tmp/pids/unicorn.pid`"
  end
end


task :init_shared_path, :roles => :web do
  run "mkdir -p #{deploy_to}/shared/log"
  run "mkdir -p #{deploy_to}/shared/pids"
end

task :link_shared_config_yaml, :roles => :web do
  run "ln -sf #{deploy_to}/shared/config/*.yml #{deploy_to}/current/config/"
  run "ln -sf #{deploy_to}/shared/config/unicorn.rb #{deploy_to}/current/config/"
end

task :restart_resque, :roles => :web do
  run "cd #{deploy_to}/current/; RAILS_ENV=production ./script/resque stop; RAILS_ENV=production ./script/resque start"
end

task :restart_resque, :roles => :web do
  run "cd #{deploy_to}/current/; RAILS_ENV=production ./script/resque stop; RAILS_ENV=production ./script/resque start"
end

task :install_gems, :roles => :web do  	
  run "cd #{deploy_to}/current/; bundle install"	  	
end

task :compile_assets, :roles => :web do	  	
  run "cd #{deploy_to}/current/; bundle exec rake assets:precompile"  	
end

task :mongoid_create_indexes, :roles => :web do
  run "cd #{deploy_to}/current/; bundle exec rake db:mongoid:create_indexes"
end

after "deploy:symlink", :init_shared_path, :link_shared_config_yaml, :install_gems, :compile_assets, :mongoid_create_indexes


set :default_environment, {
  'PATH' => "/home/ruby/.rvm/gems/ruby-1.9.3-p0/bin:/home/ruby/.rvm/gems/ruby-1.9.3-p0@global/bin:/home/ruby/.rvm/rubies/ruby-1.9.3-p0/bin:/home/ruby/.rvm/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games",
  'RUBY_VERSION' => 'ruby-1.9.3-p0',
  'GEM_HOME' => '/home/ruby/.rvm/gems/ruby-1.9.3-p0',
  'GEM_PATH' => '/home/ruby/.rvm/gems/ruby-1.9.3-p0:/home/ruby/.rvm/gems/ruby-1.9.3-p0@global'
}
