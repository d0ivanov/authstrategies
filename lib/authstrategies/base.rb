require_relative 'helpers'
require_relative 'config'
require_relative 'routes'

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
