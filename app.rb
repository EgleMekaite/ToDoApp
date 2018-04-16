require 'sinatra'
#require 'sinatra/flash'
require 'sequel'
require 'yaml'
require 'digest'
require 'pry'
require_relative 'lib/routes'
require 'slim'
require 'slim/include'

class Todo < Sinatra::Application
    set :environment, :development
    
    configure do
        env = ENV['RACK_ENV'] || 'development'
        register Sinatra::Reloader
        
        also_reload 'lib/*.rb'
        # also_reload 'views/*.slim'
        also_reload 'models/*.rb'
        after_reload do
            puts "reloaded at #{Time.now}"
        end
        DB = Sequel.connect(YAML.load(File.open('database.yml'))[env])
    end
    
    enable :sessions
    # Do not throw exception if model cannot be saved. Just return nil
    Sequel::Model.raise_on_save_failure = false
    # Sequel plugins loaded by ALL models.
    Sequel::Model.plugin :validation_helpers

    Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }
    Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| load lib }
end
