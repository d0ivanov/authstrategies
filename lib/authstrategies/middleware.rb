require "warden"

module Authstrategies
  Warden::Strategies.add(:password) do
    def valid?
      params[:username] || params[:password]
    end

    def authenticate!
      success!(User.new(params[:username], params[:password]))
    end
  end

  def self.registered(app)
    app.get "/login/?" do
      %q{
      <form action="/login" method="post">
        <input type="text" name="username" />
        <input type="password" name="password" />
        <input type="submit" name="Submit" value="Submit">
      </form>
      }
    end

    app.post "/login/?" do
      env['warden'].authenticate(:password)
    end

    app.post "/logout/?" do
      env['warden'].logout
    end
  end
end
