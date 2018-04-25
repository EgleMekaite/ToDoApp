# frozen_string_literal: true

require 'pry'

class Todo < Sinatra::Application
  get '/login/?' do
    # show a login page
    @new_user = User.new
    if session[:user_id].nil?
      slim :'authentication/login'
    else
      slim :'authentication/error', locals: { error: 'You are logged in' }
    end
  end

  post '/login/?' do
    # validate user credentials
    @logged_user = User.find_by_login(params[:name], params[:password])
    if @logged_user.nil?
      slim :'authentication/login'
    else
      session[:user_id] = @logged_user.id
      redirect '/lists'
    end
  end

  get '/signup/?' do
    # show signup form
    @new_user = User.new
    if session[:user_id].nil?
      slim :'authentication/signup'
    else
      slim :'authentication/error', locals: { error: 'Please log out first' }
    end
  end

  post '/signup/?' do
    @new_user = User.new(name: params[:name], new_password: params[:password])
    if @new_user.save
      session[:user_id] = @new_user.id
      redirect '/lists'
    else
      slim :'authentication/signup'
    end
  end

  get '/logout/?' do
    session[:user_id] = nil
    flash[:success] = 'You have successfully logged out'
    redirect '/login'
  end
end
