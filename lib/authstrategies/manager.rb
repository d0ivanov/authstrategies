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

    def call(env)
      @env = env
      env["authstrategies"] = @auth_strategies
      @auth_strategies.each { |_, strategy| strategy.load(env) }

      @app.call(env)
    end
  end
end
