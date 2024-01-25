require 'bundler/setup'
require './Control_module_of_API_endpoint.rb'  # Adjust this to the correct path to your Sinatra app
Bundler.require(:default, ENV['RACK_ENV'] || 'development')

# Set the environment to production
ENV['RACK_ENV'] ||= 'production'

# Initialize your application
run Sinatra::Application
