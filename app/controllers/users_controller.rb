class UsersController < ApplicationController

  get '/users/:slug' do
    if logged_in?
      if @user = User.find_by_slug(params[:slug])
        erb :'users/show'
      else
        @items = Item.all
        erb :'items/items', locals: {message: "I don't recognize the user whose items you tried to view."}
      end
    else
      erb :'users/login', locals: {message: "Please sign in to view content."}
    end
  end

  get '/signup' do
    if !logged_in?
      erb :'users/create_user', locals: {message: "Please sign up before you sign in"}
    else
      redirect to '/items'
    end
  end

  post '/signup' do
    @user=User.new
    @user.username = params[:username]
    @user.email = params[:email]
    @user.password = params[:password]

    if @user.save
      session[:user_id] = @user.id
      redirect to '/items'
    else
      erb :'users/create_user'
    end
  end

  get '/login' do
    if !logged_in?
      erb :'users/login'
    else
      redirect to '/items'
    end
  end

  post '/login' do
    user = User.find_by(:username => params[:username])
    if user && user.authenticate(params[:password])
      session[:user_id] = user.id
      redirect to '/items'
    else
      redirect to '/signup'
    end
  end

  get '/logout' do
    if logged_in?
      session.destroy
      redirect to '/login'
    else
      redirect to '/'
    end
  end
end
