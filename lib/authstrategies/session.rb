require "cookie_manager"
require "security_manager"

module AuthStrategies
  class Session
    COOKIE_NAME = "authstrategies.session"
    COOKIE_MANAGER = "authstrategies.session.manager"

    def initialize(app, secret)
      @app = app

      @security_manager = SecurityManager.new(secret)
      @cookie_manager = CookieManager.new Marshaller.new
    end

    def call(env)
      request = Rack::Request.new(env)
      cookies = get_cookies(request.cookies)
      @cookie_manager.load cookies

      env[COOKIE_MANAGER] = @cookie_manager

      if @cookie_manager.cookies[COOKIE_NAME.to_sym].nil?
        @cookie_manager.set COOKIE_NAME, {}
      end

      env[COOKIE_NAME] = @cookie_manager.cookies[COOKIE_NAME.to_sym]

      status, headers, body = @app.call(env)
      response = Rack::Response.new body, status, headers

      set_cookies(response)
      response.finish
    end

    private

    def get_cookies(cookie_data)
      cookies = {}

      cookie_data.values.each do |cookie|
        unpacked_cookie = @security_manager.unpack(cookie)
        if !unpacked_cookie.nil?
          cookies[upnacked_cookie.name] = unpacked_cookie.value
        end
      end

      cookies
    end

    def set_cookies(response)
      @cookie_manager.deleted_cookies.each do |cookie|
        response.delete_cookie cookie.name, cookie.value
      end

      @cookie_manager.dump.each do |marshalled_value, cookie|
        response.set_cookie(cookie.name,
          value: @security_manager.pack(marshalled_value),
          path: cookie.value[:path],
          expires: cookie.value[:expires])
      end
    end
  end
end
