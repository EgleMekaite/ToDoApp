class Todo < Sinatra::Application
  get '/lists' do
      @lists = List.association_join(:permissions).where(user_id: @user.id)
      slim :'/lists/lists'
  end
      
      get '/lists/:list_id' do
        list = List.first(id: params[:list_id])
        list_items = list.items_dataset.order(Sequel.desc(:starred))
        @comments = list.comments
        @new_comment = Comment.new
        slim :'lists/list', locals: { list_items: list_items, list: list }
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
          slim :'lists/list', locals: { list_items: list_items, list: list } 
        end
        
      end
      
      get '/new/?' do
        # show create list page
        @new_list = List.new
        @items = @new_list.items
        @item_errors = []
        slim :'lists/new_list'
      end
      
      post '/new/?' do
        # create a list
        @new_list = List.new(name: params[:name])
        @item_params = params[:items] || []
        @items = []
        @item_errors = []
        #binding.pry
        DB.transaction do
          if @new_list.save
      
            @permission = @new_list.add_permission(user: @user, permission_level: 'read_write')
      
            @item_params.each do |item_attributes|
              item = Item.new(list: @new_list, user: @user)
              item.update_fields(item_attributes, [:name, :description, :starred, :created_at, :updated_at, :due_date])
              item[:starred].nil? ? checked = 0 : checked = 1
              item.starred = checked
              @items << item
            end
      
            if @items.any? { |i| i.errors.any? } || @new_list.errors.any?
              @items.each { |i|  @item_errors << i.errors.on(:name).join }
              raise Sequel::Rollback
            else
              redirect "/lists/#{@new_list.id}"
            end
      
          end
        end
        slim :'lists/new_list'
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
          slim :'lists/edit_list'
        else
          slim :'authentication/error', locals: {error: 'Invalid permissions'}
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
          slim :'lists/edit_list'
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
end