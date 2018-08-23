require_relative 'pattern'
require_relative 'route'

class Run < OpenStruct
  ROUTE_TYPE = 0

  def self.from_id(id)
    self.new($ptv.run_for_run_id_and_route_type(id, ROUTE_TYPE))
  end

  def pattern
    Pattern.from_id(self.run_id)
  end

  def route
    Route.from_id(self.route_id)
  end
end