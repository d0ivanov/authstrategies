module AuthStrategies
  class Strategy
    def initialize(&block)
      instance_eval(&block)
    end
  end

  class StrategyManager
    def initialize
      @strategies = {}
    end

    def register(name, &block)
      raise "Name cannot be nil!" unless !name.nil?
      strategy = Strategy.new(&block)

      if !strategy.respond_to? "valid?".to_sym
        raise "Strategy must implement #valid?"
      end

      if !strategy.respond_to? "authenticate!".to_sym
        raise "Strategy must implement #authenticate!"
      end

      @strategies[name] = strategy
    end

    def get(name)
      @strategies[name]
    end

    def strategies
      @strategies
    end
  end

  class Manager
    def initialize(app, &block)
      @app = app
      @strategy_manager = StrategyManager.new
    end

    def call(env)
      env["authstrategies"] = @strategy_manager
      @app.call(env)
    end
  end
end
