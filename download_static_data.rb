require 'ruby_ptv'
require 'json'
require_relative 'secrets'

$ptv = RubyPtv::Client.new(dev_id: PTV_ID, secret_key: PTV_SECRET)

puts 'Downloading routes...'
routes = $ptv.routes(route_types: [0])
puts 'Saving...'
File.open('static/routes.json', 'w') {|f| f.write(JSON.pretty_generate(routes))}

directions = {}
puts 'Downloading directions...'
routes.each do |route|
  puts "  for route #{route['route_id']}"
  directions[route['route_id']] = $ptv.directions_for_route(route['route_id'])
end

puts 'Saving...'
File.open('static/directions.json', 'w') {|f| f.write(JSON.pretty_generate(directions))}