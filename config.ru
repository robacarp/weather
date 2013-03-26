require 'rubygems'
require 'bundler'

Bundler.require

require './weather'
run Sinatra::Application
