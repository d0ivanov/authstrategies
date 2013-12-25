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
				t.string :email,							:null => false, :defautl => ""
				t.string :encrypted_password, :null => false, :default => ""

				t.string  :remember_token
				t.boolean :remember_me

				t.timestamps
			end

			add_index :users, :email,			     :unique => true
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

To authenticate a user call authenticate!
To check if a user is authenticated call authenticated?
To get the currently logged in user call current_user
To logout the user class logout.

login_path returns the login path as a string
logout_path returns the logout path as a string
signup_path returns the signup path as a string
## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
