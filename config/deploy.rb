set :application, "pnrapi"
set :repository,  "git@github.com:alagu/pnrapi-ruby.git"
set :user, "alagu"
set :deploy_to, "/home/alagu/pnrapi"

role :web, "198.101.212.213", "198.101.212.248", "198.101.212.15"
role :resque, "198.101.212.213"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

set :unicorn_conf, "#{deploy_to}/shared/config/unicorn.rb"
set :unicorn_pid, "#{deploy_to}/shared/tmp/pids/unicorn.pid" 
set :resque_pid,  "#{deploy_to}/shared/tmp/pids/resque.pid" 
set :public_children, []
set :shared_children, %w(log tmp)
set :default_environment, {
  'PATH' => "/home/alagu/.rvm/rubies/ruby-1.9.3-p385/bin/:/home/alagu/.rvm/gems/ruby-1.9.3-p385/bin/:$PATH"
}

namespace :deploy do
 
  task :restart do
    run "if [ -f #{unicorn_pid} ]; then kill -9 `cat #{unicorn_pid}`; else cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E development -D  -l 0.0.0.0:3001; fi"
  end
 
  task :start do
    run "cd #{deploy_to}/current && bundle exec unicorn -c #{unicorn_conf} -E development -D -l 0.0.0.0:3001"
  end
 
  task :stop do
    run "if [ -f #{unicorn_pid} ]; then kill -9 `cat #{unicorn_pid}`; fi"
  end
 
end

namespace :resque  do
  task :start, :roles => :resque do
    run "cd #{deploy_to}/current && PIDFILE=#{resque_pid} BACKGROUND=yes QUEUE=stats \
    rake resque:work"
  end

  task :stop, :roles => :resque  do
    run "if [ -f #{resque_pid} ]; then kill -QUIT `cat #{resque_pid}`; fi"
  end
end
