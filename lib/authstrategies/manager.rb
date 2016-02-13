require "strategy"

module AuthStrategies
  class Manager
    def initialize(app, &block)
      @app = app
      @auth_strategies = StrategyManager.new

      instance_eval(&block) if block_given?
    end

    def register(name, &block)
      @auth_strategies.register name, &block
    end

    def authenticate
      @auth_strategies.each do |name, strategy|
        if strategy.valid?
          return strategy.authenticate!
        end
      end

      :fail
    end

    def call(env)
      @env = env
      env["authstrategies"] = self
      @auth_strategies.each { |_, strategy| strategy.load(env) }

      @app.call(env)
    end
  end
end
