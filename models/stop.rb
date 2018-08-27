require_relative 'departure'

class Stop < OpenStruct
  ROUTE_TYPE = 0 # 0 for metro trains

  def self.find_by_name(name)
    $ptv.search(name)['stops'].select {|stop| stop['route_type'] == 0}.map {|stop| self.new(stop)}
  end

  def self.from_id(id)
    self.new($ptv.stop(id, ROUTE_TYPE, stop_location: true, stop_amenities: true, stop_accessibility: true, stop_contact: true, stop_ticket: true))
  end

  def departures(params={})
    default_params = {look_backwards: false, max_results: 25, expand: 'run'}
    Departure.find(stop_id, default_params.merge(params)).sort_by {|dep| dep.departure_utc.to_i}
  end
end