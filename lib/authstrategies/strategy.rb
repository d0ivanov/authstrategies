module AuthStrategies
  class Strategy
    attr_accessor :params

    def initialize(&block)
      instance_eval(&block)
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
end
