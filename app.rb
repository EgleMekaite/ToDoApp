require 'sinatra'
require 'sequel'
require 'yaml'
require 'digest'
require 'pry'
require_relative 'lib/routes'

class Todo < Sinatra::Application
    set :environment, :development
    
    configure do
        env = ENV['RACK_ENV'] || 'development'
        #DB = Sequel.connect("mysql2://root:pass@mysql.getapp.docker/todo")
        DB = Sequel.connect(YAML.load(File.open('database.yml'))[env])

        Dir[File.join(File.dirname(__FILE__), 'models', '*.rb')].each { |model| require model }
        Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| load lib }
        enable :sessions
    end
end
