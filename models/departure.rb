require 'date'

require_relative 'route'
require_relative 'run'

class Departure < OpenStruct
  attr_writer :run, :stop

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

  def descriptor
    "#{scheduled_departure_utc.localtime.strftime("%H%M")} #{run.destination_name}"
  end

  def until_departure_english
    "#{departure_utc.localtime.strftime("%H%M")} #{((departure_utc.localtime - Time.now) / 60.0).round} mins #{'(live)' if live?}"
  end

  def live?
    !!self['estimated_departure_utc']
  end

  def departed?
    (departure_utc.localtime - Time.now) < 0
  end

  def route
    Route.from_id(self.route_id)
  end

  def direction
    Direction.from_id_and_route(self.direction_id, self.route_id)
  end

  def run
    return @run if @run
    Run.from_id(run_id)
  end

  def stop
    return @stop if @stop
    Stop.from_id(stop_id)
  end

  def self.find(stop_id, params={})
    max_results = params[:max_results]

    res = $ptv.departures(ROUTE_TYPE, stop_id, params)

    departures = res['departures'].map {|dep| self.new(dep)}
    runs = res['runs'].map {|id, run| [id, Run.new(run)]}.to_h

    # Map runs to departure objects
    departures.each_with_index do |dep, i|
      if runs.has_key?(dep.run_id.to_s)
        dep.run = runs[dep.run_id.to_s]
      end
    end

    return departures[0...max_results] if max_results
    departures
  end
end