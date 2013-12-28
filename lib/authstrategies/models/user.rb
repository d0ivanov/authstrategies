require 'bcrypt'
require 'sinatra/activerecord'
require 'protected_attributes'

class User < ActiveRecord::Base
	include BCrypt

	validates :email, :password, presence: true
	validates :email, uniqueness: true

	validates :password, confirmation: true
 	validates :password, length: { in: 8..20,
		too_long: "%{count} is the maximum allowed!",
		too_short: "must be at least %{count}" }

	attr_accessible :email, :password, :remember_me, :remember_me_token

	def password
		@password ||= Password.new(encrypted_password)
  end

	def password= password
    @password = password
		self.encrypted_password = Password.create(@password)
	end

	def authenticate request
		if self.password == request["password"]
			true
		else
			false
		end
	end

	def remember_me!
		self.update_attribute('remember_me', true)
		self.update_attribute('remember_token', new_token)
	end

  def forget_me!
		self.update_attribute('remember_me', false)
		self.update_attribute('remember_token', nil)
	end

	private
		def new_token
			Password.create(Time.new.to_s)
		end
end
