require 'sinatra'
require 'ruby_ptv'
require 'json'

PTV_ID = ENV['PTV_ID']
PTV_SECRET = ENV['PTV_SECRET']

require_relative 'models/stop'
require_relative 'models/direction'
require_relative 'models/route'

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
      return stop if stop.stop_name.downcase.start_with?(name.downcase)
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

get '/run/:id' do
  run = Run.from_id(params[:id])
  pattern = run.pattern
  
  # Generate title
  first_stop = pattern.departures.first.stop.stop_name
  last_stop = pattern.departures.last.stop.stop_name
  title = "#{pattern.departures.first.scheduled_departure_utc.localtime.strftime("%H%M")} #{first_stop} to #{last_stop}"

  erb :run, locals: {run: run, pattern: pattern, title: title}
end