module Authstrategies
	private
		module Base
			def self.registered(app)
				app.helpers Helpers
				include Config
				include Routes
			end
		end
end
