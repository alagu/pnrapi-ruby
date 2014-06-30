PNRAPI Ruby
===========

PNR API is a service that helps you to fetch PNR Numbers from Indian Railways programmatically.

Requirements
============
 - Basic *nix system
 - Ruby 1.9.3
 - Mongodb

Install
=======

```
$ git clone https://github.com/alagu/pnrapi-ruby.git
$ ruby script/mongodump.rb
```

Change the unicorn.rb file with the correct APP_ROOT 

```
$ bundle install
$ mkdir -p tmp/pids tmp/sockets logs
$ unicorn -c unicorn.rb -D
$ tail -f logs/*.log
```
