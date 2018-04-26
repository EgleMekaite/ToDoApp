# frozen_string_literal: true

require 'sinatra/reloader'
require 'sinatra/flash'
require_relative 'routes/application'
require_relative 'routes/authentication'
require_relative 'routes/lists'
require 'yaml'

class Todo < Sinatra::Application
  set :environment, (ENV['RACK_ENV'] || :development)
  register Sinatra::Flash
  configure do
    also_reload 'routes/*.rb'
    also_reload 'models/*.rb'
    after_reload do
      puts "reloaded at #{Time.now}"
    end
  end
  # env = ENV['RACK_ENV'] || 'development'
  DB = Sequel.connect(YAML.safe_load(File.open('database.yml'))[environment])

  enable :sessions
  # Do not throw exception if model cannot be saved. Just return nil
  Sequel::Model.raise_on_save_failure = false
  # Sequel plugins loaded by ALL models.
  Sequel::Model.plugin :validation_helpers
  # Rack middleware
  use Rack::MethodOverride

  Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }
  Dir[File.join(File.dirname(__FILE__), 'routes', '*.rb')].each { |route| require route }
end
