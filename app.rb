require 'sinatra'
require 'ruby_ptv'

require_relative './secrets'

get '/' do
  "hello world #{PTV_ID} #{PTV_SECRET}"
end