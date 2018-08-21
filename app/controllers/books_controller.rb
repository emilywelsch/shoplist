class BooksController < ApplicationController
  get '/books' do
    if logged_in?
      @books = Book.all
      erb :'books/books'
    else
      redirect to '/login'
    end
  end

  get '/books/new' do
    if logged_in?
      erb :'books/create_book'
    else
      redirect to '/login'
    end
  end

  post '/books' do
    if logged_in?
      if params[:title] == ""
        redirect to "/books/new"
      else
        @book = current_user.books.build(title: params[:title])
        if @book.save
          redirect to "/books/#{@book.id}"
        else
          redirect to "/books/new"
        end
      end
    else
      redirect to '/login'
    end
  end

  get '/books/:id' do
    if logged_in?
      @book = Book.find_by_id(params[:id])
      erb :'books/show_book'
    else
      redirect to '/login'
    end
  end

  get '/books/:id/edit' do
    if logged_in?
      @book = Book.find_by_id(params[:id])
      if @book && @book.user == current_user
        erb :'books/edit_book'
      else
        redirect to '/books'
      end
    else
      redirect to '/login'
    end
  end

  patch '/books/:id' do
    if logged_in?
      if params[:title] == ""
        redirect to "/books/#{params[:id]}/edit"
      else
        @book = Book.find_by_id(params[:id])
        if @book && @book.user == current_user
          if @book.update(title: params[:title])
            redirect to "/books/#{@book.id}"
          else
            redirect to "/books/#{@book.id}/edit"
          end
        else
          redirect to '/books'
        end
      end
    else
      redirect to '/login'
    end
  end

  delete '/books/:id/delete' do
    if logged_in?
      @book = Book.find(params[:id])
      if @book && @book.user == current_user
        @book.delete
      end
      redirect to '/books'
    else
      redirect to '/login'
    end
  end
end
