module Config
	app.use Warden::Manager do |manager|
		manager.failure_app = Unauthenticated
		manager.default_strategies :password
	end

	Warden::Strategies.add(:password, Strategies::PasswordStrategy)
end
