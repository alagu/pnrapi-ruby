set :application, "pnrapi-ruby"
set :repository,  "git@github.com:alagu/pnrapi-ruby.git"
set :user, "alagu"
set :deploy_to, "/home/alagu/pnrapi"

role :web, "198.101.212.213", "198.101.212.248", "198.101.212.15"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

#set :unicorn_conf, "#{release_path}/config/unicorn.rb"
#set :unicorn_pid, "#{deploy_to}/shared/pids/unicorn.pid"
# 
#set :public_children, ["css","img","js"]
# 
#namespace :deploy do
# 
#  task :restart do
#    run "if [ -f #{unicorn_pid} ]; then kill -USR2 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D; fi"
#  end
# 
#  task :start do
#    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E #{rack_env} -D"
#  end
# 
#  task :stop do
#    run "if [ -f #{unicorn_pid} ]; then kill -QUIT `cat #{unicorn_pid}`; fi"
#  end
# 
#end
#