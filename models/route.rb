require_relative 'direction'

class Route < OpenStruct
  def self.from_id(id)
    self.new(ROUTES.select {|r| r['route_id'] == id}[0])
  end

  def directions
    Direction.find_for_route(route_id)
  end
end