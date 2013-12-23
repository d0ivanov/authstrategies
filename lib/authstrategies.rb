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
			app.use Rack::Session::Cookie, {
				:secret => BCrypt::Password.create(Time.new.to_s),
				:expire_after => 3600
			}
			app.helpers Helpers
			app.use Warden::Manager do |manager|
				manager.failure_app = app
				manager.default_strategies :password
			end

			Warden::Strategies.add(:password, PasswordStrategy)

			app.get '/login/?' do
				redirect '/' if authenticated?
				erb :login
			end

			app.post '/login' do
				redirect '/' if authenticated?
				authenticate!
				if authenticated?
					flash[:notice] = "Logged in successfully!"
					redirect '/'
				else
					flash[:error] = env["warden"].message
					redirect '/login'
				end
			end

			app.get '/logout/?' do
				logout
				flash[:notice] = "Successfully logged out!"
				redirect '/'
			end

			app.post '/unauthenticated' do
				flash[:error] = "Invalid username or password!"
				catch :warden do
					redirect '/login'
				end
				redirect '/login'
			end

			app.get '/signup/?' do
				redirect '/' if authenticated?
				erb :signup
			end

			app.post '/signup' do
				redirect '/' if authenticated?
				user = User.new(params)
				if user.valid?
					user.save
					flash[:notice] = "Successfully signed up!"
					redirect '/'
				else
					flash[:error] = user.errors.messages
					redirect '/login'
				end
			end
		end
	end

	module RememberMe
		def self.registered(app)
			Warden::Strategies.add(:remember_me, RememberMeStrategy)
			app.before do
				env['warden'].authenticate!(:remember_me)
			end
			Warden::Manager.after_authentication do |user, auth, opts|
				if auth.winning_strategy.is_a?(RememberMeStrategy) ||
					(auth.winning_strategy.is_a?(PasswordStrategy) &&
					 auth.params['remember_me'])
					user.remember_me!  # new token
					Rack::Session::Cookies.new(app,
						:key => "authstrategies.remember",
						:secret => Bcrypt::Password.create(Time.now),
						:expire_after => 7 * 24 * 3600
					)
					env['authstrategies.remember']['token'] = user.remember_token
				end
			end

			Warden::Manager.before_logout do |user, auth, opts|
				user.forget_me!
				env.delete('authstrategies.remember')
			end
		end
	end
end

require "authstrategies/middleware.rb"
