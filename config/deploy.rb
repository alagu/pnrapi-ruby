set :application, "pnrapi-ruby"
set :repository,  "git@github.com:alagu/pnrapi-ruby.git"
set :user, "alagu"
set :deploy_to, "/home/alagu/pnrapi-ruby"

role :web, "198.101.212.213", "198.101.212.248", "198.101.212.15"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"
