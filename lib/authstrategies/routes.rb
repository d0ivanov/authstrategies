require_relative 'models/User'

module Authstrategies
	private
		module Routes
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
