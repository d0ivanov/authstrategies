# Authstrategies

[![Build Status](https://travis-ci.org/d0ivanov/authstrategies.svg?branch=master)](https://travis-ci.org/d0ivanov/authstrategies)

Warden implementation for Sinatra

## Installation

Add this line to your application's Gemfile:

    gem 'authstrategies'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install authstrategies

## Usage

In your sinatra application you must do the following:

	- Choose your database manager and configure it
	- Tell Authstrategies about it
	- Set your cookie secret.

## Configurint the database manager and using the User model

The currenly supported database managers are active record and data mapper.
You pass the information about your chosen database manager to Authstrategies
using
```ruby
	set :db_adapter, :active_record #set active record as your DB manager

	set :db_adapter, :data_mapper #set data mapper as your DB manager
```

By default if no db manager was set, active record will be used.


In order to access the user models in your app you can do the following:

```ruby
  include AuthStrategies::DatabaseManager.new.get :active_record
```

This will include the User defined for the given adapter in your app.

## Helpers

    authenticate!
To authenticate a user call

    authenticated?
To check if a user is authenticated

    logout
To logout the user

## Examples

```ruby

class YourApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database, {adapter: "sqlite3", database: "test.sqlite3"}

  set :db_adapter, :active_record
  include AuthStrategies::DatabaseManager.new.get :active_record

  set :cookie_secret, "35ad9acea6e5c22a0f8850774d17bbcac1ad7923"
  register Sinatra::AuthStrategies

  get "/authenticated" do
    if !authenticated?
      redirect "/unauthenticated"
    end

    user = User.find_by(id: current_user)
    user.email unless user.nil?
  end
```

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
