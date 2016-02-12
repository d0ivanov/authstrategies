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
      request = Rack::Request.new(env)
      @auth_strategies.each { |_, strategy| strategy.params = request.params }
      env["authstrategies"] = @auth_strategies

      @app.call(env)
    end
  end
end
