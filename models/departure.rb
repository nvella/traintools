require 'date'

class Departure < OpenStruct
  ROUTE_TYPE = 0 # 0 for metro trains

  def scheduled_departure_utc
    DateTime.parse(self['scheduled_departure_utc']).to_time
  end

  def estimated_departure_utc
    return nil if !self['estimated_departure_utc']
    DateTime.parse(self['estimated_departure_utc']).to_time
  end

  def departure_utc
    return estimated_departure_utc if estimated_departure_utc
    scheduled_departure_utc
  end

  def live?
    !!self['estimated_departure_utc']
  end

  def route
    Rotue.from_id(self.route_id)
  end

  def direction
    Direction.from_id_and_route(self.direction_id, self.route_id)
  end

  def self.find(stop_id, params={})
    $ptv.departures(ROUTE_TYPE, stop_id, params)['departures'].map {|dep| self.new(dep)}
  end
end