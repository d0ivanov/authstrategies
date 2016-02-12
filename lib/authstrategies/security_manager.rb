require "base64"

module AuthStrategies
  class SecurityManager
    def initialize(secret, algorithm = "SHA1")
      @digest = OpenSSL::Digest.new(algorithm)
      @secret = secret
    end

    def pack(data)
      encode "#{data}--#{sign(data)}"
    end

    def unpack(data)
      raw_data = decode data

      if verify raw_data
        verified_data, _ = raw_data.split "--"
        verified_data
      end
    end

    private

    def encode(message)
      Base64.strict_encode64 message
    end

    def decode(message)
      Base64.strict_decode64 message
    end

    def verify(message)
      return false if message.nil? || message.empty?

      data, signature = message.split "--"

      if !data.nil? && !data.empty? && !signature.nil? && !signature.empty?
        secure_compare signature, sign(data)
      else
        false
      end
    end

    def sign(data)
      OpenSSL::HMAC.hexdigest(@digest, @secret, data)
    end

    # Constant time string comparison.
    #
    # The values compared should be of fixed length, such as strings
    # that have already been processed by HMAC. This should not be used
    # on variable length plaintext strings because it could leak length info
    # via timing attacks.
    #
    # Courtesy of ActiveSupport::SecurityUtils
    def secure_compare(a, b)
      return false unless a.bytesize == b.bytesize

      l = a.unpack "C#{a.bytesize}"

      res = 0
      b.each_byte { |byte| res |= byte ^ l.shift }
      res == 0
    end
  end
end
