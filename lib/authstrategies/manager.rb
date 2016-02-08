require "strategy"

module AuthStrategies
  class Manager
    def initialize(app, &block)
      @app = app
      @strategy_manager = StrategyManager.new

      instance_eval(&block) if block_given?
    end

    def register(name, &block)
      @strategy_manager.register name, &block
    end

    def call(env)
      params = Rack::Request.new(env).params
      @strategy_manager.each { |name, strategy| strategy.params = params }

      env["authstrategies"] = @strategy_manager
      @app.call(env)
    end
  end
end
