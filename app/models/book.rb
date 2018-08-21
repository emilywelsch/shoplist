class Book < ActiveRecord::Base
  belongs_to :user
  has_many :book_authors
  has_many :authors, through: :book_authors


end