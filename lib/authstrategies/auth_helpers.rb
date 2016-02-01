require "sinatra/base"

module Sinatra
  module AuthStrategies
    module AuthHelper
      def authstrategies
        env["authstrategies"]
      end

      def authenticate!(name = :password)
        strategy = strategy(name)
        strategy.authenticate! unless strategy.nil?
      end

      def strategy(name)
        authstrategies.find(-> { [] }) {|key, strategy| key == name}.last
      end
    end
  end

  helpers AuthStrategies::AuthHelper
end
