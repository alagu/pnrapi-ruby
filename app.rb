require 'sinatra'
require 'dalli'
require 'json'
require 'rest_client'
require 'date'
require 'sinatra/base'
require 'mustache/sinatra'
require 'resque'
require 'user_agent'


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

  sample_response = <<RESPONSE
{
   "status":"OK",
   "data":{
      "train_number":"17017",
      "chart_prepared":false,
      "pnr_number":"8611691678",
      "train_name":"RJT SC EXPRESS",
      "travel_date":{
         "timestamp":1367193600,
         "date":"29-4-2013"
      },
      "from":{
         "code":"PUNE",
         "name":"PUNE JUNCTION",
         "time":"22:30"
      },
      "to":{
         "code":"SC",
         "name":"SECUNDERABAD JUNCTION",
         "time":"10:30"
      },
      "alight":{
         "code":"SC",
         "name":"SECUNDERABAD JUNCTION",
         "time":"10:30"
      },
      "board":{
         "code":"PUNE",
         "name":"PUNE JUNCTION",
         "time":"22:30",
         "timestamp":1367274600
      },
      "class":"SL",
      "passenger":[
         {
            "seat_number":"W/L  9,RLGN",
            "status":"W/L  3"
         },
         {
            "seat_number":"W/L  10,RLGN",
            "status":"W/L  4"
         },
         {
            "seat_number":"W/L  11,RLGN",
            "status":"W/L  5"
         }
      ]
   }
}
RESPONSE

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
    Resque.enqueue StatsJob, 'pnr_status', {:pnr => '123',
      :agent => request.user_agent.to_s, :referer => request.referer.to_s }
    "test #{request.user_agent.to_s}"
  end

  get '/api/v1.0/pnr/:pnr' do
    start_t = Time.now
    jsonp = params.fetch 'jsonp', nil
    pnr   = params.fetch 'pnr'

    if pnr == '1234567890'
      pnr_data = sample_response
    else
      Resque.enqueue StatsJob, 'pnr_status', {:pnr => pnr,
        :agent => UserAgent.parse(request.user_agent).browser, 
        :referer => request.referer.to_s
      }

      content_type 'application/json'
      cache_key = PNR_CACHE_KEY % (pnr)

      data = settings.cache.get(PNR_CACHE_KEY)

      if not data
        data = Status.fetch(pnr)
      end

      pnr_data = data.to_json
    end

  
    if jsonp
      "#{jsonp}(#{pnr_data})"
    else
      "#{pnr_data}"
    end


  end
end
