require 'sinatra'
require 'pry'

before do
  if !['login', 'signup'].include? (request.path_info.split('/')[1]) and session[:user_id].nil?
    redirect '/login'
  end
  @min_date = Time.now.strftime("%Y-%m-%dT%H:%M")
  @user = User.first(id: session[:user_id])
end
=begin
helpers do
  def current_user
    @current_user ||= User.first(id: session[:user_id]) if session[:user_id]
  end
end
=end

get '/?' do
  #binding.pry
  @lists = List.association_join(:permissions).where(user_id: @user.id)
  slim :lists
end

get '/lists/:list_id' do
  list = List.first(id: params[:list_id])
  list_items = list.items_dataset.order(Sequel.desc(:starred))
  @comments = list.comments
  @new_comment = Comment.new
  slim :list, locals: { list_items: list_items, list: list }
end

post '/new_comment/:list_id' do
  list = List.first(id: params[:list_id])
  list_items = list.items_dataset.order(Sequel.desc(:starred))
  @comments = list.comments
  comment_text = params[:comments][0][:text]
  @new_comment = Comment.new(text: comment_text)
  #binding.pry
  if @new_comment.valid?
    list.add_comment list, @user, params[:comments]
    redirect "/lists/#{list.id}"
  else
    slim :list, locals: { list_items: list_items, list: list } 
  end
  
end

get '/new/?' do
  # show create list page
  @new_list = List.new
  #binding.pry
  slim :new_list
end

post '/new/?' do
  # create a list
  @new_list = List.new_list params[:name], params[:items], @user
  @items = params[:items]
  @item_errors = []
  #binding.pry
  if !@items.nil?
    @items.each do |item|
      item = Item.new(name: item[:name])
      #binding.pry
      item.valid? ? item.save : @item_errors << item.errors.on(:name).join
    end
  end
  #binding.pry
  if @new_list.save && @item_errors.empty?
    redirect "/lists/#{@new_list.id}"
  else
    slim :new_list
  end
end

get '/edit/:list_id' do
  # check user permission and show the edit page
  list = List.first(id: params[:list_id])
  list_items = list.items
  can_edit = true
  if list.nil?
    can_edit = false
  elsif list.shared_with == 'public'
    permission = Permission.first(list: list, user: @user)
    if permission.nil? || permission.permission_level == 'read_only'
      can_edit = false
    end
  end
  if can_edit
    slim :edit_list, locals: {list: list, list_items: list_items}
  else
    slim :error, locals: {error: 'Invalid permissions'}
  end
end

post '/edit/:list_id' do
  # update the list
  list = List.first(id: params[:list_id])
  list.edit_list params[:list_id], params[:name], params[:items], params[:starred], @user
  redirect "/lists/#{list[:id]}"
end

get '/delete/:list_id' do
  list = List.first(id: params[:list_id])
  list.delete_list list.id, list.items
  redirect '/'
end

get '/delete/item/:item_id' do
  item = Item.first(id: params[:item_id])
  item.destroy
  redirect back
end

get '/delete/comment/:comment_id' do
  comment = Comment.first(id: params[:comment_id])
  creation_time = comment.creation_time
  if Time.now < creation_time + 900
    comment.destroy
  end
  redirect back
end
    
get '/signup/?' do
  # show signup form
  @new_user = User.new
  if session[:user_id].nil?
    slim :signup
  else
    slim :error, :locals => {:error => 'Please log out first'}
  end
end

post '/signup/?' do
  @new_user = User.new(name: params[:name], new_password: params[:password])
  if @new_user.save
    session[:user_id] = @new_user.id
    redirect '/'
  else
    slim :signup
  end
end

get '/login/?' do
  # show a login page
  @new_user = User.new
  if session[:user_id].nil?
    slim :login
  else
    slim :error, locals: {error: 'You are logged in'}
  end
end

post '/login/?' do
  # validate user credentials
  @logged_user = User.find_by_login(params[:name], params[:password])
  if @logged_user.nil?
    slim :login
  else
    session[:user_id] = @logged_user.id
    redirect '/'
  end
end

get '/logout/?' do
  session[:user_id] = nil
  redirect '/login'
end
