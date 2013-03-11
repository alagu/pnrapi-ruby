require "bundler/setup"
Bundler.require(:default)
require 'resque/tasks'
require './app'


task "resque:setup" do
    ENV['QUEUE'] = '*'
end
