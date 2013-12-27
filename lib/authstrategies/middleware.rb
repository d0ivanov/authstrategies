module Authstrategies
	class Middleware < Sinatra::Base
    register Base
    register RememberMe

    include Manager

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
            :expires => Time.now + 7 * 24 * 3600
          )
        end
        Manager.call :after_login, [current_user, request, response]
        flash[:notice] = "Logged in successfully!"
        redirect '/'
      end
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
        env['warden'].set_user(user)
        Manager.call :after_signup, [user, request, response]
        flash[:notice] = "Successfully signed up!"
        redirect '/'
      else
        flash[:error] = user.errors.messages
        redirect '/signup'
      end
    end

    get '/logout/?' do
      if authenticated?
        current_user.forget_me!
        response.delete_cookie("authstrategies")
        logout
        Manager.call :after_logout, [request, response]
        flash[:notice] = "Successfully logged out!"
        redirect '/'
      end
      redirect '/'
    end

    post '/unauthenticated' do
      Manager.call :after_login_failure, [request, response]
      flash[:error] = env["warden"].message
      redirect '/login'
    end
	end
end
