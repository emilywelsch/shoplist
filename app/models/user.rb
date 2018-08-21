class User < ActiveRecord::Base
  has_many :books
  has_many :authors, through: :books

  has_secure_password

  validates :email, :username, :password, presence: true

  def slug
    username.downcase.gsub(" ","-")
  end

  def self.find_by_slug(slug)
    User.all.find{|user| user.slug == slug}
  end

end
