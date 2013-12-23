require 'bcrypt'
require 'active_record'

class User < ActiveRecord::Base
	include BCrypt

	validates :email, :password, presence: true
	validates :email, uniqueness: true

	validates :password, confirmation: true
 	validates :password, length: { in: 8..20,
		too_long: "%{count} is the maximum allowed!",
		too_short: "must be at least %{count}" }

	before_save :encrypt_password

	def password
		@password ||= Password.new(encrypted_password)
  end

	def password= password
		@password = password
	end

	def authenticate request
		if self.password == request["password"]
			true
		else
			false
		end
	end

	def remember_me!
		self.update_attributes(:remember_token => new_token)
	end

  def forget_me!
		self.update_attributes(:remember_token => nil)
	end

	private
		def encrypt_password
			self.encrypted_password = Password.create(@password)
		end

		def new_token
			Password.create(Time.new.to_s)
		end

end
