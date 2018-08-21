require 'spec_helper'
require 'pry'

describe "Signup Page" do

  it 'loads the signup page' do
    get '/signup'
    expect(last_response.status).to eq(200)
  end

  it 'signup directs user to books index' do
    params = {
      :username => "skittles123",
      :email => "skittles@aol.com",
      :password => "rainbows"
    }
    post '/signup', params
    expect(last_response.location).to include("/books")
  end

  it 'does not let a user sign up without a username' do
    params = {
      :username => "",
      :email => "skittles@aol.com",
      :password => "rainbows"
    }
    post '/signup', params
    expect(last_response.body).to include('Sign Up')
  end

  it 'does not let a user sign up without an email' do
    params = {
      :username => "skittles123",
      :email => "",
      :password => "rainbows"
    }
    post '/signup', params
    expect(last_response.body).to include('Sign Up')
  end

  it 'does not let a user sign up without a password' do
    params = {
      :username => "skittles123",
      :email => "skittles@aol.com",
      :password => ""
    }
    post '/signup', params
    expect(last_response.body).to include('Sign Up')
  end

  it 'does not let a logged in user view the signup page' do
    user = User.create(:username => "skittles123", :email => "skittles@aol.com", :password => "rainbows")
    params = {
      :username => "skittles123",
      :email => "skittles@aol.com",
      :password => "rainbows"
    }
    post '/signup', params
    session = {}
    session[:user_id] = user.id
    get '/signup'
    expect(last_response.location).to include('/books')
  end
end

describe "login" do
  it 'loads the login page' do
    get '/login'
    expect(last_response.status).to eq(200)
  end

  it 'loads the books index after login' do
    user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
    params = {
      :username => "becky567",
      :password => "kittens"
    }
    post '/login', params
    expect(last_response.status).to eq(302)
    follow_redirect!
    expect(last_response.status).to eq(200)
    expect(last_response.body).to include("Welcome,")
  end

  it 'does not let user view login page if already logged in' do
    user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
    params = {
      :username => "becky567",
      :password => "kittens"
    }
    post '/login', params
    get '/login'
    expect(last_response.location).to include("/books")
  end
end

describe "logout" do
  it "lets a user logout if they are already logged in" do
    user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

    params = {
      :username => "becky567",
      :password => "kittens"
    }
    post '/login', params
    get '/logout'
    expect(last_response.location).to include("/login")
  end

  it 'does not let a user logout if not logged in' do
    get '/logout'
    expect(last_response.location).to include("/")
  end

  it 'does not load /books if user not logged in' do
    get '/books'
    expect(last_response.location).to include("/login")
  end

  it 'does load /books if user is logged in' do
    user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")


    visit '/login'

    fill_in(:username, :with => "becky567")
    fill_in(:password, :with => "kittens")
    click_on('submit')
    expect(page.current_path).to eq('/books')
  end
end

describe 'user show page' do
  it 'shows all a single users books' do
    user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
    book1 = Book.create(:title => "tweeting!", :user_id => user1.id)
    book2 = Book.create(:title => "look at this tweet", :user_id => user1.id)

    visit '/login'

    fill_in(:username, :with => "becky567")
    fill_in(:password, :with => "kittens")
    click_button 'submit'

    visit "/users/#{user1.slug}"
    expect(last_response.body).to include("tweeting!")
    expect(last_response.body).to include("look at this tweet") 
  end
end

