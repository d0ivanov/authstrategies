require "sinatra/base"

module Sinatra
  module AuthStrategies
    module AuthHelpers
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
end
