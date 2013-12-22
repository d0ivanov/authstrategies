require "authstrategies/version"
require "warden"
require "rack-flash"
require "sinatra/base"
require "activerecord"
require "authstrategies/models/User"
require "authstrategies/helpers"

module Authstrategies
	private
		class Warden::SessionSerializer
			def serialize(user)
				user.id
			end

			def deserialize(id)
				User.find(id)
			end
		end

		class PasswordStrategy < Warden::Strategies::Base
			def valid?
				!!(request["email"] && request["password"])
			end

			def authenticate!
				user = User.find_by_email(request["email"])
				if user && user.authenticate(request)
					success!(user)
				else
					fail!("Invalid username or password")
				end
			end
		end

		module Base
			def self.registered(app)
				app.helpers Helpers
				app.use Warden::Manager do |manager|
					manager.failure_app = app
					manager.default_strategies :password
				end

				Warden::Strategies.add(:password, Strategies::PasswordStrategy)

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

		class Middleware < Sinatra::Base
			register Base
		end
end
