module Authstrategies
	class Middleware < Sinatra::Base
			register Base
			register RememberMe

			get '/login/?' do
				redirect '/' if authenticated?
				erb :login
			end

			post '/login' do
				redirect '/' if authenticated?
				authenticate!
				if authenticated?
					if params["remember_me"] == "on"
						current_user.remember_me!
						response.set_cookie("authstrategies",
							:value => current_user.remember_token,
							:expire => 7 * 24 * 3600
						)
					end
					flash[:notice] = "Logged in successfully!"
					redirect '/'
				else
					flash[:error] = env["warden"].message
					redirect '/login'
				end
			end

			get '/logout/?' do
				if authenticated?
					current_user.forget_me!
					response.delete_cookie("authstrategies")
					logout
					flash[:notice] = "Successfully logged out!"
					redirect '/'
				end
				redirect '/'
			end

			post '/unauthenticated' do
				flash[:error] = env["warden"].message
				redirect '/login'
			end

			get '/signup/?' do
				redirect '/' if authenticated?
				erb :signup
			end

			post '/signup' do
				redirect '/' if authenticated?
				user = User.new(params)
				if user.valid?
					user.save
					flash[:notice] = "Successfully signed up!"
					redirect '/'
				else
					flash[:error] = user.errors.messages
					redirect '/signup'
				end
			end
	end
end
