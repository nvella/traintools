class Direction < OpenStruct
  ROUTE_TYPE = 0 # 0 for metro trains

  def self.from_id_and_route(id, route)
    self.new(DIRECTIONS["#{route}"].select {|dir| dir['direction_id'] == id}[0])
  end

  def self.find_for_route(route_id)
    DIRECTIONS["#{route}"].map {|dirs| self.new(dirs)}
  end
end