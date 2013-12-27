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

    # This is called every time the user is set. The user is set:
    # => on each request when they are accessed for the first time via env['warden'].user
    # => when the user is initially authenticated
    # => when the user is set via the set_user method
    # Courtesy of Warden, for more information
    # check the warden callbacks wiki
    def self.after_set_user &block
      Warden::Manager.after_set_user do |user, auth, opts|
        yield(user, auth, opts)
      end
    end

    # Executed every time the user is authenticated
    # (first time in each session).
    # Courtesy of Warden, for more information
    # check the warden callbacks wiki
    def self.after_authentication &block
      Warden::Manager.after_authentication do |user, auth, opts|
        yield(user, auth, opts)
      end
    end

    # This callback is run right before the failure application is called.
    # Courtesy of Warden, for more information
    # check the warden callbacks wiki
    def self.before_login_failure &block
      Warden::Manager.before_failure do |env, opts|
        yield(env, opts)
      end
    end

    # This is called in the failure application
    # Useful for redirecting the user after he logs in
    # 2 params are passed to this callback
    # =>request - the request data
    # =>response - the response data
    def self.after_login_failure &block
      self.register :on_login_failure, &block
    end

    #This callback is run before each user is logged out.
    # Courtesy of Warden, for more information
    # check the warden callbacks wiki
    def self.before_logout &block
      Warden::Manager.before_logout do |user, auth, opts|
        yield(user, auth, opts)
      end
    end

    # This is called after the user is logged out.
    # Useful for redirecting the user after logging out
    # 2 parameters are passed to this callback
    # =>request - the request data
    # =>response - the response data
    def self.after_logout &block
      self.register :after_logout, &block
    end

    # This is called each time after the user logs in
    # 3 parameters are passed to this callback
    # =>current_user - the user that hase just been set
    # =>request - the request data
    # =>response - the response data
    def self.after_login &block
      self.register :on_login, block
    end

    # This is called after the user is saved into
    # the database
    # 3 parameters are passed to this callback
    # =>user - the user that just signed up
    # =>request - the request data
    # =>response - the response data
    # Also since the user is set to session via env['warden'].set_user
    # after_set_user is also called after the user signs up
    def self.after_signup &block
      self.register :after_register, &block
    end

    private
      @@callbacks = {}

      def self.register hook, &block
        if @@callbacks[hook].class == Array
          @@callbacks[hook].push block
        else
          @@callbacks[hook] = [block]
        end
      end

      def self.call hook, args = []
        if @@callbacks.has_key? hook
          @@callbacks[hook].each do |callback|
            callback.call(args)
          end
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

			Manager.before_login_failure do |env,opts|
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
