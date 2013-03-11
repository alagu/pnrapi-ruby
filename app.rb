require 'sinatra'
require 'dalli'
require 'json'
require 'rest_client'
require 'date'
require 'sinatra/base'
require 'mustache/sinatra'
require 'resque'


base_path = File.join(File.dirname(__FILE__))

require File.join(base_path, 'config.rb')
require File.join(base_path, 'models', 'status.rb')
require File.join(base_path, 'models', 'trains.rb')
require File.join(base_path, 'tasks', 'stats_job.rb')

client        = MongoClient.new('localhost', 27017)
DB            = client['pnrapi']
TWO_WEEKS     = 1209600
HALF_DAY      = 43200
PNR_CACHE_KEY = "pnr:%s"
Resque.redis  = "198.101.212.213:6379"


set :public_folder, File.dirname(__FILE__) + '/public'

Sinatra.register Mustache::Sinatra

class App < Sinatra::Base
  require './views/layout.rb'

  configure do
    register Mustache::Sinatra
    set :environment, :development
    set :cache, Dalli::Client.new
    set :mustache, {
      :views     => './views',
      :templates => './templates'
    }
  end


  get '/' do
    @title = "Mustache + Sinatra = Wonder"
    mustache 'index'
  end

  get '/test' do
    Resque.enqueue StatsJob, 'pnr_status', {:pnr => '123' }
    "test"
  end

  get '/api/v1.0/pnr/:pnr' do
    start_t = Time.now
    jsonp = params.fetch 'jsonp', nil
    pnr   = params.fetch 'pnr'

    Resque.enqueue StatsJob, 'pnr_status', {:pnr => pnr }

    content_type 'application/json'
    cache_key = PNR_CACHE_KEY % (pnr)

    data = settings.cache.get(PNR_CACHE_KEY)

    if not data
      data = Status.fetch(pnr)
    end
    end_t = Time.now
    rtt = ((end_t - start_t) * 1000).to_i.to_s

    data['rtt'] = rtt 
    Resque.enqueue StatsJob, 'rtt', {:rtt => rtt.to_i }


    if jsonp
      "#{jsonp}(#{data.to_json})"
    else
      "#{data.to_json}"
    end
  end
end
