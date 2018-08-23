require_relative 'departure'

class Pattern
  ROUTE_TYPE = 0

  attr_accessor :departures, :stops

  def initialize
    @departures = [] # Departures in order from first to last
    @stops = {} # Stops referenced by this pattern
    @runs = {} # Runs referenced by this pattern
  end

  def self.from_id(id, params = {expand: 'all'})
    pattern = Pattern.new
    
    data = $ptv.pattern(id, ROUTE_TYPE, params)
    pattern.departures = data['departures'].map {|dep| Departure.new(dep)}
    pattern.stops = data['stops'].map {|k, stop| [k.to_i, Stop.new(stop)]}.to_h

    # Expand in data
    pattern.departures.each do |dep| # Stops into departures
      p dep.inspect
      dep.stop = pattern.stops[dep.stop_id] if pattern.stops.has_key? dep.stop_id
    end
    
    pattern
  end
end