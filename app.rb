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
        #Dir[File.join(File.dirname(__FILE__), 'lib', '*.rb')].each { |lib| load lib }
        enable :sessions
    end
end


before do
  if !['login', 'signup'].include? (request.path_info.split('/')[1]) and session[:user_id].nil?
    redirect '/login'
  end
end


get '/?' do
    
      user = User.first(id: session[:user_id])
      all_lists = List.association_join(:permissions).where(user_id: user.id)
      haml :lists, locals: {lists: all_lists}
  end
  
  get '/new/?' do
      # show create list page
      haml :new_list
  end
  
  post '/new/?' do
      # create a list
      user = User.first(id: session[:user_id])
      list = List.new_list params[:name], params[:items], user
      redirect "/"
  end
  
  get '/edit/:id/?' do
      # check user permission and show the edit page
      list = List.first(id: params[:id])
      can_edit = true
  
      if list.nil?
          can_edit = false
      elsif list.shared_with == 'public'
          user = User.first(id: session[:user_id])
          permission = Permission.first(list: list, user: user)
          if permission.nil? or permission.permission_level == 'read_only'
          can_edit = false
          end
      end
  
      if can_edit
      haml :edit_list, locals: {list: list}
      else
      haml :error #:locals => {:error => 'Invalid permissions'}
      end
  end
  
  post '/edit/?' do
      # update the list
      user = User.first(id: session[:user_id])
      List.edit_list params[:id], params[:name], params[:items], user
      redirect request.referer
  end
  
  post '/permission/?' do
      # update permission
      user = User.first(id: session[:user_id])
      list = List.first(id: params[:id])
      can_change_permission = true
      if list.nil?
          can_change_permission = false
      elsif list.shared_with != 'public'
          permission = Permission.first(list: list, user: user)
          if permission.nil? or permission.permission_level == 'read_only'
              can_change_permission = false
          end
      end
      if can_change_permission
          list.permission = params[:new_permissions]
          list.save
          current_permissions = Permission.first(list: list)
          current_permissions.each do |perm|
              perm.destroy
          end
          if params[:new_permissions] == 'private' or parms[:new_permissions] == 'shared'
              user_perms.each do |perm|
                  u = User.first(perm[:user])
                  Permission.create(list: list, user: u, permission_level: perm[:level], created_at: Time.now, updated_at: Time.now)
              end
          end
          redirect request.referer
      else
          haml :error, locals: {error: 'Invalid permissions'}
      end
  end
  
  get '/signup/?' do
      # show signup form
      
      if session[:user_id].nil?
          haml :signup
      else
          haml :error, :locals => {:error => 'Please log out first'}
      end
  end
  
  post '/signup/?' do
     
      md5sum = Digest::MD5.hexdigest params[:password]
      user = User.create(name: params[:name], password: md5sum, created_at: Time.now)
      session[:user_id] = user.id
         redirect '/'
  end
  
  get '/login/?' do
      # show a login page
      
      if session[:user_id].nil?
          haml :login
      else
          haml :error, locals: {error: 'You are logged in'}
      end
  end
  
  post '/login/?' do
      # validate user credentials
      md5sum = Digest::MD5.hexdigest params[:password]
         user = User.first(name: params[:name], password: md5sum)
      if user.nil?
          haml :error, locals: {error: 'Invalid username or password'}
      else
             session[:user_id] = user.id
          redirect '/'
      end
  end
  
  get '/logout/?' do
      session[:user_id] = nil
      redirect '/login'
  end
  