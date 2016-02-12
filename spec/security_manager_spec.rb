require "security_manager"
require "base64"

describe "SecurityManager" do

  before :each do
    @digest = OpenSSL::Digest::SHA1.new
    @sm = AuthStrategies::SecurityManager.new("much_secret_such_secure")
  end

  describe "#pack" do
    it "Packs data in a way it can be unpacked and read" do
      packed_data = @sm.pack("secure message")

      expect(@sm.unpack(packed_data)).to eq "secure message"
    end

    it "Protects against malicious modifications on the value" do
      malicious_hash = @digest.digest("malicious")
      malicious_message = Base64.strict_encode64("malicious--" + malicious_hash)

      expect(@sm.unpack(malicious_message)).to be nil
    end
  end

  describe "#unpack" do
    it "Cannot unpack message with empty content" do
      hash = @digest.digest("")
      malicious_message = Base64.strict_encode64("--#{hash}")

      expect(@sm.unpack(malicious_message)).to be nil
    end

    it "Cannot unpack a message without a hash" do
      malicious_message = Base64.strict_encode64("text--")

      expect(@sm.unpack(malicious_message)).to be nil
    end
  end
end
