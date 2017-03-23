require 'bcrypt'

class User < ActiveRecord::Base
  validates :username, uniqueness: true
  validates :username, presence: true

  has_secure_password
end
