require_relative 'departure'

class Pattern
  ROUTE_TYPE = 0

  attr_accessor :departures, :stops

  def initialize
    @departures = [] # Departures in order from first to last
    @stops = {} # Stops referenced by this pattern
    @runs = {} # Runs referenced by this pattern
  end

  def descriptor
    # Generate title
    first_stop = @departures.first.stop.stop_name
    last_stop = @departures.last.stop.stop_name
    "#{@departures.first.scheduled_departure_utc.localtime.strftime("%H%M")} #{first_stop} to #{last_stop}"
  end

  def self.from_id(id, params = {expand: 'all'})
    pattern = Pattern.new
    
    data = $ptv.pattern(id, ROUTE_TYPE, params)
    pattern.departures = data['departures'].map {|dep| Departure.new(dep)}
    pattern.stops = data['stops'].map {|k, stop| [k.to_i, Stop.new(stop)]}.to_h

    # Expand in data
    pattern.departures.each do |dep| # Stops into departures
      dep.stop = pattern.stops[dep.stop_id] if pattern.stops.has_key? dep.stop_id
    end

    pattern
  end
end