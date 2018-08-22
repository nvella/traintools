require 'sinatra'
require 'ruby_ptv'
require 'json'

require_relative 'secrets'
require_relative 'models/stop'
require_relative 'models/direction'

DIRECTIONS = JSON.parse(File.read('static/directions.json'))
ROUTES = JSON.parse(File.read('static/routes.json'))

$ptv = RubyPtv::Client.new(dev_id: PTV_ID, secret_key: PTV_SECRET)

RubyPtv.configure(
  dev_id: PTV_ID,
  secret_key: PTV_SECRET
)

helpers do
  def quick_find_stop(name)
    stops = Stop.find_by_name(name)
    stops.each do |stop|
      return stop if stop.stop_name.start_with?(name)
    end
    stops[0]    
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end
end

get '/' do
  erb :index, locals: {info: nil}
end

post '/' do
  # Attempt to find the stop params[:stop]
  stop = quick_find_stop(params[:stop])
  if !stop.nil?
    redirect to("/stop/#{stop.stop_id}")
  else
    erb :index, locals: {info: 'Stop not found'}
  end
end

get '/stop/:id' do
  stop = Stop.from_id(params[:id])
  departures = stop.departures

  erb :stop, locals: {stop: stop, departures: departures}
end