require "cookie_manager"

describe "CookieManager" do
  def cookie_jar
    {test0: AuthStrategies::Cookie.new("test0", "value0", "/", Time.now),
     test1: AuthStrategies::Cookie.new("test1", "value1", "/", Time.now) }
  end

  def create_cookie(name, value, path, expire)
    AuthStrategies::Cookie.new(name, value, path, expire)
  end

  before :each do
    @marshaller = AuthStrategies::Marshaller.new
    @manager = AuthStrategies::CookieManager.new @marshaller
  end

  describe "#set" do
    it "Can set cookies" do
      @manager.set"name", "value", "/", Time.now + 24 * 3600

      expect(@manager.cookies[:name]).not_to be nil
      expect(@manager.cookies[:name]).to eq "value"
    end

    it "Cannot set a cookie larger thatn 4KB" do
      big_value = "a" * 4097

      expect {@manager.set "name", big_value, "/", Time.now + 24 * 3600}
            .to raise_error(ArgumentError)
    end

    it "Cannot set a cookie without a value" do
      expect {@manager.set "name", nil, "/", Time.now}
        .to raise_error(ArgumentError)
    end

    it "Cannot set a cookie without a name" do
      expect {@manager.set nil, "value", "/", Time.now}
        .to raise_error(ArgumentError)
    end
  end

  describe "#delete" do
    it "Can delete cookies" do
      @manager.set "name", "value", "/", Time.now + 10
      expect(@manager.cookies[:name]).not_to be nil

      @manager.delete(:name)
      expect(@manager.cookies[:name]).to be nil
    end
  end

  describe "#load" do
    it "Can load cookies from an unpacked cookie hash" do
      cookies = cookie_jar.map do |name, cookie|
        [name, @marshaller.marshal(cookie)]
      end.to_h

      @manager.load cookies

      expect(@manager.cookies[:test0]).not_to be nil
      expect(@manager.cookies[:test0]).to eq "value0"

      expect(@manager.cookies[:test1]).not_to be nil
      expect(@manager.cookies[:test1]).to eq "value1"
    end
  end
end
