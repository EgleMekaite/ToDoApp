require_relative 'lib/routes'
require 'yaml'

class Todo < Sinatra::Application
  set :environment, :development
  
  configure do
    register Sinatra::Reloader
    also_reload 'routes/*.rb'
    also_reload 'models/*.rb'
    after_reload do
      puts "reloaded at #{Time.now}"
    end
  end
  env = ENV['RACK_ENV'] || 'development'
  DB = Sequel.connect(YAML.load(File.open('database.yml'))[env])

  enable :sessions
  # Do not throw exception if model cannot be saved. Just return nil
  Sequel::Model.raise_on_save_failure = false
  # Sequel plugins loaded by ALL models.
  Sequel::Model.plugin :validation_helpers  
  # Rack middleware
  use Rack::MethodOverride

  Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }
  Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| require lib }
  #Dir[File.join(File.dirname(__FILE__), 'routes', '*.rb')].each { |route| require route }
end
