require "authstrategies/version"
require "warden"
require "rack-flash"
require "sinatra/base"
require "active_record"
require "bcrypt"
require "authstrategies/session_serializer.rb"
require "authstrategies/helpers.rb"
require "authstrategies/password.rb"
require "authstrategies/remember_me.rb"
require "authstrategies/models/user.rb"

module Authstrategies
	module Base
		def self.registered(app)
			app.helpers Helpers

			app.use Warden::Manager do |manager|
				manager.failure_app = app
				manager.default_strategies :password
			end

			Warden::Manager.before_failure do |env,opts|
						env['REQUEST_METHOD'] = 'POST'
			end
			Warden::Strategies.add(:password, PasswordStrategy)
		end
	end

	module RememberMe
		def self.registered(app)
			Warden::Strategies.add(:remember_me, RememberMeStrategy)
		end
	end
end
require "authstrategies/middleware.rb"
