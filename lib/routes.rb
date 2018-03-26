require 'sinatra'

before do
    if !['login', 'signup'].include? (request.path_info.split('/')[1]) and session[:user_id].nil?
      redirect '/login'
    end
end
  
get '/?' do
    user = User.first(id: session[:user_id])
    all_lists = List.association_join(:permissions).where(user_id: user.id)
    slim :lists, locals: {lists: all_lists}
end

get '/lists/:list_id' do
    list = List.first(id: params[:list_id])
    list_items = list.items
    slim :list, locals: {list_items: list_items, list: list }
end
    
get '/new/?' do
    # show create list page
    slim :new_list
end

post '/new/?' do
    # create a list
    user = User.first(id: session[:user_id])
    list = List.new_list params[:name], params[:items], user
    redirect "/"
end
    
get '/edit/:list_id' do
    # check user permission and show the edit page
    list = List.first(id: params[:list_id])
    list_items = list.items
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
    slim :edit_list, locals: {list: list, list_items: list_items}
    else
    slim :error, locals: {error: 'Invalid permissions'}
    end
end
    
post '/edit/:list_id' do
    # update the list
    user = User.first(id: session[:user_id])
    list = List.first(id: params[:list_id])
    list.edit_list params[:list_id], params[:name], params[:items], user
    redirect '/'
end

get '/delete/:list_id' do
    list = List.first(id: params[:list_id])
    list.delete_list list.id, list.items
    redirect '/'
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
        slim :signup
    else
        slim :error, :locals => {:error => 'Please log out first'}
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
        slim :login
    else
        slim :error, locals: {error: 'You are logged in'}
    end
end
    
post '/login/?' do
    # validate user credentials
    md5sum = Digest::MD5.hexdigest params[:password]
    user = User.first(name: params[:name], password: md5sum)
    if user.nil?
        slim :error, locals: {error: 'Invalid username or password'}
    else
        session[:user_id] = user.id
        redirect '/'
    end
end

get '/logout/?' do
    session[:user_id] = nil
    redirect '/login'
end
