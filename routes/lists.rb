# frozen_string_literal: true

class Todo < Sinatra::Application
  get '/lists/?' do
    @lists = List.association_join(:permissions).where(user_id: @user.id)
    slim :'/lists/lists'
  end

  get '/lists/new/?' do
    # show create list page
    @list = List.new
    @items = @list.items
    @item_errors = []
    slim :'lists/edit_list'
  end

  post '/lists/new/?' do
    # create a list
    @list = List.new(name: params[:name])
    @item_params = params[:items] || []
    @items = []
    @item_errors = []
    DB.transaction do
      if @list.save
        @permission = @list.add_permission(user: @user, permission_level: 'read_write')
        @item_params.each do |item_attributes|
          item = Item.new(list: @list, user: @user)
          item.update_fields(item_attributes, %i[name description starred created_at updated_at due_date])
          checked = item[:starred].nil? ? 0 : 1
          item.starred = checked
          @items << item
        end

        if @items.any? { |i| i.errors.any? } && @list.errors.any?
          @items.each { |i| @item_errors << i.errors.on(:name).join }
          raise Sequel::Rollback
        elsif @list.errors.none? && @items.any? { |i| i.errors.any? }
          @items.each { |i| @item_errors << i.errors.on(:name).join }
          flash[:warning] = "List '#{@list.name}' has been successfully created but your items could not be saved"
          redirect "/lists/#{@list.id}/edit"
        else
          flash[:success] = "List '#{@list.name}' has been successfully created"
          redirect "/lists/#{@list.id}"
        end
      end
    end
    slim :'lists/edit_list'
  end

  get '/lists/:list_id/?' do
    list = List.first(id: params[:list_id])
    list_items = list.items.nil? ? [] : list.items_dataset.order(Sequel.desc(:starred))
    @comments = list.comments
    @new_comment = Comment.new
    slim :'lists/list', locals: { list_items: list_items, list: list }
  end

  post '/lists/:list_id/new_comment/?' do
    list = List.first(id: params[:list_id])
    list_items = list.items_dataset.order(Sequel.desc(:starred))
    @comments = list.comments
    @new_comment = Comment.new(text: params[:text])
    if @new_comment.valid?
      @new_comment.set(list: list, user: @user)
      @new_comment.save
      list.save
      redirect "/lists/#{list.id}"
    else
      slim :'lists/list', locals: { list_items: list_items, list: list }
    end
  end

  get '/lists/:list_id/edit' do
    # show the edit page
    @list = List.first(id: params[:list_id])
    @items = @list.items
    @item_errors = []
    can_edit = true
    if @list.nil?
      can_edit = false
    elsif @list.shared_with == 'public'
      permission = Permission.first(list: @list, user: @user)
      can_edit = false if permission.nil? || permission.permission_level == 'read_only'
    end
    if can_edit
      slim :'lists/edit_list'
    else
      slim :'authentication/error', locals: { error: 'Invalid permissions' }
    end
  end

  post '/lists/:list_id/edit' do
    # update the list
    @list = List.first(id: params[:list_id])
    @item_params = params[:items] || []
    @items = []
    @item_errors = []
    DB.transaction do
      @list.name = params[:name]
      @item_params.each do |item_attributes|
        item = @list.items_dataset[id: item_attributes[:id]] || Item.new(list: @list, user: @user)
        item.update_fields(item_attributes, %i[name description starred created_at updated_at due_date])
        checked = item[:starred].nil? ? 0 : 1
        item.starred = checked
        @items << item
      end
      if @list.save
        if @items.any? { |i| i.errors.any? } || @list.errors.any?
          @items.each { |i| @item_errors << i.errors.on(:name).join if i.errors.any? }
          # binding.pry
          raise Sequel::Rollback
        else
          flash[:success] = "'#{@list.name}' has been successfully updated"
          redirect "/lists/#{@list.id}"
        end
      end
    end
    slim :'/lists/edit_list'
  end

  get '/lists/:list_id/delete' do
    list = List.first(id: params[:list_id])
    flash[:success] = "'#{list[:name]}' has been deleted"
    list.delete_list list.id, list.items
    redirect '/lists'
  end

  get '/lists/:list_id/items/:item_id/delete' do
    item = Item.first(id: params[:item_id])
    item.destroy
    redirect back
  end

  get '/lists/:list_id/comments/:comment_id/delete' do
    comment = Comment.first(id: params[:comment_id])
    creation_time = comment.creation_time
    comment.destroy if Time.now < creation_time + 900
    redirect back
  end
end
