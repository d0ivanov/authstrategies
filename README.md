# Authstrategies

Warden implementation for Sinatra

## Installation

Add this line to your application's Gemfile:

    gem 'authstrategies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install authstrategies

## Usage

Authstrategies uses sinatra-activerecord as orm. There is currently no rake task to generate a migration for the user model, but you can use the following: (courtesy of device)

    def up
      create_table :users do |t|
        t.string :email,              :null => false, :defautl => ""
        t.string :encrypted_password, :null => false, :default => ""

        t.string  :remember_token
        t.boolean :remember_me

        t.timestamps
      end

      add_index :users, :email,          :unique => true
      add_index :users, :remember_token, :unique => true
    end


After that your application should be configurad similarly to the following:

    require 'authstrategies'

		class YourApp < Sinatra::Application
			use Rack::Session::Cookie, {
				:secret => 'such secret many secure wow',
				:expire_after => 3600
			}
			use Rack::Flash
			use Authstrategies::Middleware
		end

The expire after for Rack::Session::Cookie is optional, but I set it, because
some modern browsers will not delete session cookies after the user closes his browser like you would normally expect. This may pose a security thread if your users log in from a public computer.

If you want to use the helpers provided with authstrategies put:

		require 'authstrategies/helpers'

		helpers Authstrategies::Helpers

in your code.

## Helpers

    authenticate!
To authenticate a user call

    authenticated?
To check if a user is authenticated

    current_user
To get the currently logged in user

    logout
To logout the user

    login_path
returns the login path as a string

    logout_path
returns the logout path as a string

    signup_path
returns the signup path as a string

## Callbacks

    after_set_user
This is called every time the user is set. The user is set:
  on each request when they are accessed for the first time via env['warden'].user
  when the user is initially authenticated
  when the user is set via the set_user method
Courtesy of Warden, for more information check the warden callbacks wiki

    after_authentication

Executed every time the user is authenticated
(first time in each session).
Courtesy of Warden, for more information check the warden callbacks wiki

    before_login_failure

This callback is run right before the failure application is called.
Courtesy of Warden, for more information
check the warden callbacks wiki

    after_login_failure

This is called in the failure application
Useful for redirecting the user after he logs in
2 params are passed to this callback
  request - the request data
  response - the response data

    before_logout

This callback is run before each user is logged out.
Courtesy of Warden, for more information
check the warden callbacks wiki

    after_logout

This is called after the user is logged out.
Useful for redirecting the user after logging out
2 parameters are passed to this callback
  request - the request data
  response - the response data

    after_login

This is called each time after the user logs in
3 parameters are passed to this callback
  current_user - the user that hase just been set
  request - the request data
  response - the response data

    after_signup

This is called after the user is saved into
the database
3 parameters are passed to this callback
  user - the user that just signed up
  request - the request data
  response - the response data
Also since the user is set to session via env['warden'].set_user
after_set_user is also called after the user signs up

## Configuration

You can cofigure authstrategies throug:

    Authstrategies::Manager.config do |config|
     config[:after_login_path] = '/' #sets a path to redirect the user after logging in
     config[:after_login_msg] = 'Successfully logged in!' #sets a message to give to the user after he logs in

     config[:after_logout_path] = '/' #sets a path to redirect the user after logging out
     config[:after_logout_msg] = 'Successfully logged out!' #sets a message to give to the user after he logs out

     config[:after_signup_path] = '/' #sets a path to redirect the user after he signs up
     config[:after_signup_msg] = 'Successfully signed up!' #sets a message to give to the user after he signs up
    end

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
