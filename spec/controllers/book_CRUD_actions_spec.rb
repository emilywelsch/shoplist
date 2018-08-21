require 'spec_helper'
require 'pry'


describe 'index action' do
  context 'logged in' do
    it 'lets a user view the books index if logged in' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book1 = Book.create(:title => "tweeting!", :user_id => user1.id)

      user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
      book2 = Book.create(:title => "tweet tweet tweet", :user_id => user2.id)

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit "/books"
      expect(page.body).to include(book1.title)
      expect(page.body).to include(book2.title)
    end
  end

  context 'logged out' do
    it 'does not let a user view the books index if not logged in' do
      get '/books'
      expect(last_response.location).to include("/login")
    end
  end
end

describe 'new action' do
  context 'logged in' do
    it 'lets user view new book form if logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit '/books/new'
      expect(page.status_code).to eq(200)
    end

    it 'lets user create a book if they are logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'

      visit '/books/new'
      fill_in(:title, :with => "tweet!!!")
      click_button 'submit'

      user = User.find_by(:username => "becky567")
      book = Book.find_by(:title => "tweet!!!")
      expect(book).to be_instance_of(Book)
      expect(book.user_id).to eq(user.id)
      expect(page.status_code).to eq(200)
    end

    it 'does not let a user book from another user' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'

      visit '/books/new'

      fill_in(:title, :with => "tweet!!!")
      click_button 'submit'

      user = User.find_by(:id=> user.id)
      user2 = User.find_by(:id => user2.id)
      book = Book.find_by(:title => "tweet!!!")
      expect(book).to be_instance_of(Book)
      expect(book.user_id).to eq(user.id)
      expect(book.user_id).not_to eq(user2.id)
    end

    it 'does not let a user create a blank book' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'

      visit '/books/new'

      fill_in(:title, :with => "")
      click_button 'submit'

      expect(Book.find_by(:title => "")).to eq(nil)
      expect(page.current_path).to eq("/books/new")
    end
  end

  context 'logged out' do
    it 'does not let user view new book form if not logged in' do
      get '/books/new'
      expect(last_response.location).to include("/login")
    end
  end
end

describe 'show action' do
  context 'logged in' do
    it 'displays a single book' do

      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book = Book.create(:title => "i am a boss", :user_id => user.id)

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'

      visit "/books/#{book.id}"
      expect(page.status_code).to eq(200)
      expect(page.body).to include("Delete Book")
      expect(page.body).to include(book.title)
      expect(page.body).to include("Edit Book")
    end
  end

  context 'logged out' do
    it 'does not let a user view a book' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book = Book.create(:title => "i am a boss", :user_id => user.id)
      get "/books/#{book.id}"
      expect(last_response.location).to include("/login")
    end
  end
end

describe 'edit action' do
  context "logged in" do
    it 'lets a user view book edit form if they are logged in' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book = Book.create(:title => "tweeting!", :user_id => user1.id)
      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit '/books/1/edit'
      expect(page.status_code).to eq(200)
      expect(page.body).to include(book.title)
    end

    it 'does not let a user edit a book they did not create' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book1 = Book.create(:title => "tweeting!", :user_id => user1.id)

      user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
      book2 = Book.create(:title => "tweet tweet tweet", :user_id => user2.id)

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      session = {}
      session[:user_id] = user1.id
      visit "/books/#{book2.id}/edit"
      expect(page.current_path).to include('/books')
    end

    it 'lets a user edit their own book if they are logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book = Book.create(:title => "tweeting!", :user_id => user.id)
      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit '/books/1/edit'

      fill_in(:title, :with => "i love tweeting")

      click_button 'submit'
      expect(Book.find_by(:title => "i love tweeting")).to be_instance_of(Book)
      expect(Book.find_by(:title => "tweeting!")).to eq(nil)
      expect(page.status_code).to eq(200)
    end

    it 'does not let a user edit a text with blank content' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book = Book.create(:title => "tweeting!", :user_id => user.id)
      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit '/books/1/edit'

      fill_in(:title, :with => "")

      click_button 'submit'
      expect(Book.find_by(:title => "i love tweeting")).to be(nil)
      expect(page.current_path).to eq("/books/1/edit")
    end
  end

  context "logged out" do
    it 'does not load -- instead redirects to login' do
      get '/books/1/edit'
      expect(last_response.location).to include("/login")
    end
  end
end

describe 'delete action' do
  context "logged in" do
    it 'lets a user delete their own book if they are logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book = Book.create(:title => "tweeting!", :user_id => user.id)
      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit 'books/1'
      click_button "Delete Book"
      expect(page.status_code).to eq(200)
      expect(Book.find_by(:title => "tweeting!")).to eq(nil)
    end

    it 'does not let a user delete a book they did not create' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      book1 = Book.create(:title => "tweeting!", :user_id => user1.id)

      user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
      book2 = Book.create(:title => "look at this tweet", :user_id => user2.id)

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit "books/#{book2.id}"
      click_button "Delete Book"
      expect(page.status_code).to eq(200)
      expect(Book.find_by(:title => "look at this tweet")).to be_instance_of(Book)
      expect(page.current_path).to include('/books')
    end
  end

  context "logged out" do
    it 'does not load let user delete a book if not logged in' do
      book = Book.create(:title => "tweeting!", :user_id => 1)
      visit '/books/1'
      expect(page.current_path).to eq("/login")
    end
  end
end

