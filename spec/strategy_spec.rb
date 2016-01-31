require "strategy"

describe "StrategyManager" do
    before :each do
      @strategies = AuthStrategies::StrategyManager.new
      @strategy = Proc.new do
        def valid?
        end

        def authenticate!
        end
      end
    end

  describe "#register" do
    it "registers a strategy that implements #valid? and #authenticate!" do
      @strategies.register(:test, &@strategy)

      expect(@strategies.get(:test)).not_to be nil
      expect(@strategies.get(:test)).to be_instance_of AuthStrategies::Strategy
    end

    it "registered strategies respond to #valid? or #authenticate!" do
      @strategies.register(:test, &@strategy)

      expect(@strategies.get(:test)).to respond_to "valid?"
      expect(@strategies.get(:test)).to respond_to "authenticate!"
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

      expect(@strategies.get(:password).valid?).to be == "plain"
      expect(@strategies.get(:password).authenticate!).to be == "plain"
    end
  end

  describe "#get" do
    it "returns the correct strategy" do
      @strategies.register(:password) do
        def valid?
          "password"
        end

        def authenticate!
          "password"
        end
      end

      @strategies.register(:plain) do
        def valid?
          "plain"
        end

        def authenticate!
          "plain"
        end
      end

      expect(@strategies.get(:password).valid?).to be == "password"
      expect(@strategies.get(:password).authenticate!).to be == "password"

      expect(@strategies.get(:plain).valid?).to be == "plain"
      expect(@strategies.get(:plain).authenticate!).to be == "plain"
    end
  end
end
