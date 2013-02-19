set :application, "pnrapi-ruby"
set :repository,  "git@github.com:alagu/pnrapi-ruby.git"
set :user, "alagu"
set :deploy_to, "/home/alagu/pnra

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

role :web, "198.101.212.213", "198.101.212.248", "198.101.212.15"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts
