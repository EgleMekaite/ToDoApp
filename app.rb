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
            puts 'reloaded'
        end
        #DB = Sequel.connect("mysql2://root:pass@mysql.getapp.docker/todo")
        DB = Sequel.connect(YAML.load(File.open('database.yml'))[env])

        Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }
        Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| load lib }
        enable :sessions
        enable :reloader
    end
end
