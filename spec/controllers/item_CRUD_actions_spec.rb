require 'spec_helper'
require 'pry'


describe 'index action' do
  context 'logged in' do
    it 'lets a user view the items index if logged in' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item1 = Item.create(:name => "shopping!", :user_id => user1.id)

      user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
      item2 = Item.create(:name => "shop shop shop", :user_id => user2.id)

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit "/items"
      expect(page.body).to include(item1.name)
      expect(page.body).to include(item2.name)
    end
  end

  context 'logged out' do
    it 'does not let a user view the items index if not logged in' do
      get '/items'
      expect(last_response.location).to include("/login")
    end
  end
end

describe 'new action' do
  context 'logged in' do
    it 'lets user view new item form if logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit '/items/new'
      expect(page.status_code).to eq(200)
    end

    it 'lets user create a item if they are logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'

      visit '/items/new'
      fill_in(:name, :with => "shop!!!")
      click_button 'submit'

      user = User.find_by(:username => "becky567")
      item = Item.find_by(:name => "shop!!!")
      expect(item).to be_instance_of(Item)
      expect(item.user_id).to eq(user.id)
      expect(page.status_code).to eq(200)
    end

    it 'does not let a user item from another user' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'

      visit '/items/new'

      fill_in(:name, :with => "shop!!!")
      click_button 'submit'

      user = User.find_by(:id=> user.id)
      user2 = User.find_by(:id => user2.id)
      item = Item.find_by(:name => "shop!!!")
      expect(item).to be_instance_of(Item)
      expect(item.user_id).to eq(user.id)
      expect(item.user_id).not_to eq(user2.id)
    end

    it 'does not let a user create a blank item' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'

      visit '/items/new'

      fill_in(:name, :with => "")
      click_button 'submit'

      expect(Item.find_by(:name => "")).to eq(nil)
      expect(page.current_path).to eq("/items/new")
    end
  end

  context 'logged out' do
    it 'does not let user view new item form if not logged in' do
      get '/items/new'
      expect(last_response.location).to include("/login")
    end
  end
end

describe 'show action' do
  context 'logged in' do
    it 'displays a single item' do

      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item = Item.create(:name => "i am a boss", :user_id => user.id)

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'

      visit "/items/#{item.id}"
      expect(page.status_code).to eq(200)
      expect(page.body).to include("Delete Item")
      expect(page.body).to include(item.name)
      expect(page.body).to include("Edit Item")
    end
  end

  context 'logged out' do
    it 'does not let a user view a item' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item = Item.create(:name => "i am a boss", :user_id => user.id)
      get "/items/#{item.id}"
      expect(last_response.location).to include("/login")
    end
  end
end

describe 'edit action' do
  context "logged in" do
    it 'lets a user view item edit form if they are logged in' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item = Item.create(:name => "shopping!", :user_id => user1.id)
      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit '/items/1/edit'
      expect(page.status_code).to eq(200)
      expect(page.body).to include(item.name)
    end

    it 'does not let a user edit a item they did not create' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item1 = Item.create(:name => "shopping!", :user_id => user1.id)

      user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
      item2 = Item.create(:name => "shop shop shop", :user_id => user2.id)

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      session = {}
      session[:user_id] = user1.id
      visit "/items/#{item2.id}/edit"
      expect(page.current_path).to include('/items')
    end

    it 'lets a user edit their own item if they are logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item = Item.create(:name => "shopping!", :user_id => user.id)
      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit '/items/1/edit'

      fill_in(:name, :with => "i love shopping")

      click_button 'submit'
      expect(Item.find_by(:name => "i love shopping")).to be_instance_of(Item)
      expect(Item.find_by(:name => "shopping!")).to eq(nil)
      expect(page.status_code).to eq(200)
    end

    it 'does not let a user edit a text with blank content' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item = Item.create(:name => "shopping!", :user_id => user.id)
      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit '/items/1/edit'

      fill_in(:name, :with => "")

      click_button 'submit'
      expect(Item.find_by(:name => "i love shopping")).to be(nil)
      expect(page.current_path).to eq("/items/1/edit")
    end
  end

  context "logged out" do
    it 'does not load -- instead redirects to login' do
      get '/items/1/edit'
      expect(last_response.location).to include("/login")
    end
  end
end

describe 'delete action' do
  context "logged in" do
    it 'lets a user delete their own item if they are logged in' do
      user = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item = Item.create(:name => "shopping!", :user_id => user.id)
      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit 'items/1'
      click_button "Delete Item"
      expect(page.status_code).to eq(200)
      expect(Item.find_by(:name => "shopping!")).to eq(nil)
    end

    it 'does not let a user delete a item they did not create' do
      user1 = User.create(:username => "becky567", :email => "starz@aol.com", :password => "kittens")
      item1 = Item.create(:name => "shopping!", :user_id => user1.id)

      user2 = User.create(:username => "silverstallion", :email => "silver@aol.com", :password => "horses")
      item2 = Item.create(:name => "look at this shop", :user_id => user2.id)

      visit '/login'

      fill_in(:username, :with => "becky567")
      fill_in(:password, :with => "kittens")
      click_button 'submit'
      visit "items/#{item2.id}"
      click_button "Delete Item"
      expect(page.status_code).to eq(200)
      expect(Item.find_by(:name => "look at this item")).to be_instance_of(Item)
      expect(page.current_path).to include('/items')
    end
  end

  context "logged out" do
    it 'does not load let user delete a item if not logged in' do
      item = Item.create(:name => "shopping!", :user_id => 1)
      visit '/items/1'
      expect(page.current_path).to eq("/login")
    end
  end
end
