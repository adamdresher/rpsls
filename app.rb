# frozen_string_literal: true

require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

get '/' do
  'Wubba lubba dub dub!'
end
