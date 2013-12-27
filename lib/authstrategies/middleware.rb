module Authstrategies
	class Middleware < Sinatra::Base
    register Base
    register RememberMe

    include Manager
    get '/login/?' do
      redirect '/' if authenticated?
      erb :login
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
        Manager.call :after_signup, user
        env['warden'].set_user(user)
        flash[:notice] = "Successfully signed up!"
        redirect '/'
      else
        flash[:error] = user.errors.messages
        redirect '/signup'
      end
    end

    post '/unauthenticated' do
      Manager.call :after_login_failure
      flash[:error] = env["warden"].message
      redirect '/login'
    end
	end
end
