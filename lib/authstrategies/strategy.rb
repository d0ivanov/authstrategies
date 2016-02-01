module AuthStrategies
  class Strategy
    attr_accessor :params

    def initialize(&block)
      instance_eval(&block)
    end
  end

  class StrategyManager
    include Enumerable

    def initialize(&block)
      @strategies = {}
      instance_eval(&block) if block_given?
    end

    def each(&block)
      @strategies.each(&block)
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
  end

  class Manager
    def initialize(app, &block)
      @app = app
      @strategy_manager = StrategyManager.new(&block)
    end

    def call(env)
      params = Rack::Request.new(env).params
      @strategy_manager.each { |name, strategy| strategy.params = params }

      env["authstrategies"] = @strategy_manager
      @app.call(env)
    end
  end
end
