require_relative 'route'
require_relative 'stop'
require_relative 'direction'

class Run < OpenStruct
  ROUTE_TYPE = 0

  def self.from_id(id)
    self.new($ptv.run_for_run_id_and_route_type(id, ROUTE_TYPE))
  end
end