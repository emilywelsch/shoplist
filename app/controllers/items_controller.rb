class ItemsController < ApplicationController
  get '/items' do
    if logged_in?
      @items = Item.all
      erb :'items/items'
    else
      redirect to '/login'
    end
  end

  get '/items/new' do
    if logged_in?
      erb :'items/create_item'
    else
      redirect to '/login'
    end
  end

  post '/items' do
    if logged_in?
      if params[:name] == ""
        redirect to "/items/new"
      else
        @item = current_user.items.build(name: params[:name])
        if @item.save
          redirect to "/items/#{@item.id}"
        else
          redirect to "/items/new"
        end
      end
    else
      redirect to '/login'
    end
  end

  get '/items/:id' do
    if logged_in?
      @item = Item.find_by_id(params[:id])
      erb :'items/show_item'
    else
      redirect to '/login'
    end
  end

  get '/items/:id/edit' do
    if logged_in?
      @item = Item.find_by_id(params[:id])
      if @item && @item.user == current_user
        erb :'items/edit_item'
      else
        redirect to '/items'
      end
    else
      redirect to '/login'
    end
  end

  patch '/items/:id' do
    if logged_in?
      if params[:name] == ""
        redirect to "/items/#{params[:id]}/edit"
      else
        @item = Item.find_by_id(params[:id])
        if @item && @item.user == current_user
          if @item.update(name: params[:name])
            redirect to "/items/#{@item.id}"
          else
            redirect to "/items/#{@item.id}/edit"
          end
        else
          redirect to '/items'
        end
      end
    else
      redirect to '/login'
    end
  end

  delete '/items/:id/delete' do
    if logged_in?
      @item = Item.find(params[:id])
      if @item && @item.user == current_user
        @item.delete
      end
      redirect to '/items'
    else
      redirect to '/login'
    end
  end
end
