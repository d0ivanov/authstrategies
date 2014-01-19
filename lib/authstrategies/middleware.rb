module Authstrategies
	class Middleware < Sinatra::Base
    register Base
    register RememberMe

    use Rack::Locale

    include Manager

    I18n::Backend::Simple.send(:include, I18n::Backend::Fallbacks)
    I18n.load_path = Dir[File.join(File.dirname(__FILE__)+'/locales', '*.yml')]
    I18n.backend.load_translations
    I18n.enforce_available_locales = true
    I18n.default_locale = Manager.config[:default_locales]

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
        flash[:notice] = I18n.t 'login_msg'
        redirect Manager.config[:after_login_path]
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
        flash[:notice] = I18n.t 'signup_msg'
        redirect Manager.config[:after_signup_path]
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
        flash[:notice] = I18n.t 'logout_msg'
        redirect Manager.config[:after_logout_path]
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
