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
  module Manager

    #This is called every time the user is set. The user is set:
    # => on each request when they are accessed for the first time via env['warden'].user
    # => when the user is initially authenticated
    # => when the user is set via the set_user method
    # Courtesy of Warden
    def self.after_set_user &block
      Warden::Manager.after_set_user do |user, auth, opts|
        yield(user, auth, opts)
      end
    end

    #Executed every time the user is authenticated
    #(first time in each session).
    #Courtesy of Warden
    def self.after_authentication &block
      Warden::Manager.after_authentication do |user, auth, opts|
        yield(user, auth, opts)
      end
    end

    #This callback is run right before the failure application is called.
    #Courtesy of Warden
    def self.before_login_failure &block
      Warden::Manager.before_failure do |env, opts|
        yield(env, opts)
      end
    end

    #This is called in the failure application
    #Useful for redirecting the user after he logs in
    def self.after_login_failure &block
      self.register :on_login_failure, &block
    end

    #This callback is run before each user is logged out.
    #Courtesy of Warden
    def self.before_logout &block
      Warden::Manager.before_logout do |user, auth, opts|
        yield(user, auth, opts)
      end
    end

    #This is called after the user is logged out.
    #Useful for redirecting the user after logging out
    def self.after_logout &block
      self.register :after_logout, &block
    end

    #This is called each time after the user logs in
    def self.after_login block
      self.register :on_login, &block
    end

    #This is called after the user is saved into
    #the database
    def self.after_signup &block
      self.register :after_register, &block
    end

    def self.register hook, &block
      @@callbacks[hook] = block
    end

    private
      @@callbacks = {}

      def self.call hook, args = []
        @@callbacks[hook].call(args) if @@callbacks.has_key? hook
      end
  end

	module Base
    def self.registered(app)
			app.helpers Helpers
      app.use Warden::Manager do |manager|
        manager.failure_app = app
        manager.default_strategies :password
      end

			Manager.before_login_failure do |env,opts|
				env['REQUEST_METHOD'] = 'POST'
			end
			Warden::Strategies.add(:password, PasswordStrategy)
      include Manager

      app.post '/login' do
        redirect '/' if authenticated?
        authenticate!
        if authenticated?
          Manager.call :after_login, current_user
          flash[:notice] = "Logged in successfully!"
          redirect '/'
        end
      end

      app.get '/logout/?' do
        if authenticated?
          logout
          Manager.call :after_logout
          flash[:notice] = "Successfully logged out!"
          redirect '/'
        end
        redirect '/'
      end
    end
	end

	module RememberMe
		def self.registered(app)
			Warden::Strategies.add(:remember_me, RememberMeStrategy)
      include Manager
      app.post '/login' do
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
          Manager.call :after_login, current_user
          flash[:notice] = "Logged in successfully!"
          redirect '/'
        end
      end

     app.get '/logout/?' do
        if authenticated?
          current_user.forget_me!
          response.delete_cookie("authstrategies")
          logout
          Manager.call :after_logout
          flash[:notice] = "Successfully logged out!"
          redirect '/'
        end
        redirect '/'
      end
    end
  end
end
require "authstrategies/middleware.rb"
