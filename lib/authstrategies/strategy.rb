module AuthStrategies
  class Strategy
    def initialize(&block)
      instance_eval(&block)
    end

    def load(env)
      @env = env
      @request = Rack::Request.new(env)
      @params = @request.params
    end

    private

    def fail!
      :failed
    end

    def success!(user)
      return :success, user
    end
  end

  class StrategyManager
    include Enumerable

    def initialize
      @strategies = {}
    end

    def each(&block)
      @strategies.each(&block)
    end

    def register(name, &block)
      if name.nil? || name.empty?
        raise "Name can be neither nil nor empty!"
      end
      strategy = Strategy.new(&block)

      if !strategy.respond_to? "valid?".to_sym
        raise "Strategy must implement #valid?"
      end

      if !strategy.respond_to? "authenticate!".to_sym
        raise "Strategy must implement #authenticate!"
      end

      @strategies[name] = strategy
    end

    def authenticate
      @strategies.each do |name, strategy|
        if strategy.valid?
          return strategy.authenticate!
        end
      end

      return :fail, "/"
    end
  end
end
