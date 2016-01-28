require 'bcrypt'

module AuthStrategies
  class User
    attr_reader :username, :email

    def initialize(username, password)
      @password, @username = password, username
    end

    # Authenticates a user based on a given usernme password
    # Returns a user object if the authentication was successful,
    # nil otherwise
    def self.authenticate(username, password)
      raise NotImplementedError "This action has not beed defined!"
    end
  end
end
