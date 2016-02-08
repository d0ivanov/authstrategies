require "strategy"

describe "StrategyManager" do
    before :each do
      @strategy = Proc.new do
        def valid?
        end

        def authenticate!
        end
      end

      @strategies = AuthStrategies::StrategyManager.new
    end

    def strategy(name)
      @strategies.find(-> { [] }) {|key, strategy| key == name}.last
    end

  describe "#register" do
    it "registers a strategy that implements #valid? and #authenticate!" do
      @strategies.register(:test, &@strategy)

      expect(strategy(:test)).not_to be nil
      expect(strategy(:test)).to be_instance_of AuthStrategies::Strategy
    end

    it "registered strategies respond to #valid? or #authenticate!" do
      @strategies.register(:test, &@strategy)

      expect(strategy(:test)).to respond_to "valid?"
      expect(strategy(:test)).to respond_to "authenticate!"
    end

    it "cannot register a strategy wihtout a name" do
      expect { @strategies.register(nil, &@strategy) }.to raise_error(RuntimeError)
    end

    it "Strategies with duplicate names override eachother" do
      @strategies.register(:password) do
        def valid?
          "password"
        end

        def authenticate!
          "password"
        end
      end

      @strategies.register(:password) do
        def valid?
          "plain"
        end

        def authenticate!
          "plain"
        end
      end

      expect(strategy(:password).valid?).to be == "plain"
      expect(strategy(:password).authenticate!).to be == "plain"
    end
  end
end
