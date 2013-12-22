module Authstrategies
	module Helpers
		def authenticate!
			env['warden'].authenticate!
		end

		def authenticated?
			env['warden'].authenticated?
		end

		def current_user
			env['warden'].user
		end

		def logout
			env['warden'].logout
		end
	end
end
