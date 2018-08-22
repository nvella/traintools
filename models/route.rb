require_relative 'direction'

class Route < OpenStruct
  def self.from_id(id)
    self.new(ROUTES[id])
  end

  def directions
    Direction.find_for_route(route_id)
  end
end