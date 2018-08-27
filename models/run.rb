require_relative 'pattern'
require_relative 'route'

class Run < OpenStruct
  ROUTE_TYPE = 0
  NEXT_SERVICE_TIME_TOLERANCE = 60 * 2 # 2 MINUTES

  def self.from_id(id)
    self.new($ptv.run_for_run_id_and_route_type(id, ROUTE_TYPE))
  end

  def pattern
    Pattern.from_id(self.run_id)
  end

  def route
    Route.from_id(self.route_id)
  end

  def next_service_id
    # Find the next service ran by this train.
    # Usually at the same platform and departing around/after the arrival

    pat = self.pattern
    last_departure = pat.departures.last

    # Find departures at last stop near this time and platform
    departures_at_last = Departure.find(last_departure.stop_id, {
      platform_numbers: [last_departure.platform_number],
      look_backwards: false
    })
    
    departures_at_last = departures_at_last.select {|dep| dep.scheduled_departure_utc > (last_departure.scheduled_departure_utc - NEXT_SERVICE_TIME_TOLERANCE) && 
        dep.scheduled_departure_utc < (last_departure.scheduled_departure_utc + NEXT_SERVICE_TIME_TOLERANCE)}
      .sort_by {|dep| dep.departure_utc.to_i}

    return nil if departures_at_last.empty?
    departures_at_last[0].run_id
  end
end