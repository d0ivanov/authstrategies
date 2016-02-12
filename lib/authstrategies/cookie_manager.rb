require "yaml"

module AuthStrategies
  class CookieManager
    MAX_COOKIE_SIZE = 4096

    attr_accessor :deleted_cookies

    def initialize(marshaller)
      @deleted_cookies = []
      @cookies = []

      @marshaller = marshaller
    end

    def set(name, value, path = "/", expire = Time.now)
      cookie = Cookie.new name, value, path, expire

      if @marshaller.marshal(cookie).bytesize >= MAX_COOKIE_SIZE
        raise ArgumentError.new(
          "Max cookie size is #{MAX_COOKIE_SIZE}, #{value.bytesize} given!")
      end

      @cookies.push(cookie)
    end

    def delete(*names)
      @cookies.delete_if do |kookie|
        @deleted_cookies << kookie if names.include? kookie.name.to_sym
      end
    end

    def cookies
      @cookies.map {|cookie| [cookie.name.to_sym, cookie.value[:value]]}.to_h
    end

    def load(cookies)
      cookies.each do |_, cookie|
        @cookies << @marshaller.unmarshal(cookie)
      end
    end

    def dump
      @cookies.map { |cookie| [@marshaller.marshal(cookie), cookie] }.to_h
    end
  end

  class Marshaller
    def marshal(data)
      data.to_yaml
    end

    def unmarshal(data)
      YAML.load(data)
    end
  end

  class Cookie
    attr_reader :name, :value

    def initialize(name, value, path, expire)
      if value.nil? || name.nil?
        raise ArgumentError.new "Value and name must not be nil!"
      end

      @name = name
      @value = {name: name, value: value, path: path, expire: expire}
    end
  end
end
