require 'sinatra'
require 'dalli'
require 'json'
require 'rest_client'
require 'date'

require File.join(File.dirname(__FILE__), 'models.rb')

set :cache, Dalli::Client.new


get '' do
  "Hello World!"
end


TWO_WEEKS    = 1209600
HALF_DAY     = 43200
PNR_CACHE_KEY = "pnr:%s"

get '/api/v1.0/pnr/:pnr' do
  jsonp = params.fetch 'jsonp', nil
  pnr   = params.fetch 'pnr'

  content_type 'application/json'
  cache_key = PNR_CACHE_KEY % (pnr)

  data = settings.cache.get(PNR_CACHE_KEY)

  if not data
    data = Status.fetch(pnr)
  end


  if jsonp
    "#{jsonp}(#{data.to_json})"
  else
    "#{data.to_json}"
  end
end