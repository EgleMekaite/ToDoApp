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
  slim :new_list
end

post '/new/?' do
  # create a list
  @new_list = List.new_list params[:name], params[:items], @user
  @items = @new_list.items
  @item_errors = []
  @item_errors << 'Item name cannot be blank' if @items.empty?
  if !@items.nil?
    @items.each do |item|
      item.valid? ? item.save : @item_errors << item.errors.on(:name).join
    end
  end
  if @new_list.valid? && @item_errors.empty?
    Permission.create(list: @new_list, user: @user, permission_level: 'read_write', created_at: Time.now,
      updated_at: Time.now)
    @new_list.save
    redirect "/lists/#{@new_list.id}"
  else
    slim :new_list
  end
end

get '/edit/:list_id' do
  # show the edit page
  @edited_list = List.first(id: params[:list_id])
  @items = @edited_list.items
  can_edit = true
  if @edited_list.nil?
    can_edit = false
  elsif @edited_list.shared_with == 'public'
    permission = Permission.first(list: @edited_list, user: @user)
    if permission.nil? || permission.permission_level == 'read_only'
      can_edit = false
    end
  end
  if can_edit
    slim :edit_list
  else
    slim :error, locals: {error: 'Invalid permissions'}
  end
end

post '/edit/:list_id' do
  # update the list
  @edited_list = List.first(id: params[:list_id])
  @edited_list.edit_list params[:list_id], params[:name], params[:items], @user
  @items = params[:items]
  
  if @edited_list.save 
    redirect "/lists/#{@edited_list[:id]}"
  else
    slim :edit_list
  end
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
