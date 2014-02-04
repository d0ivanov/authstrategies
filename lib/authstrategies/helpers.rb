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

		def login_path
			'/login'
		end

		def logout_path
			'/logout'
		end

		def signup_path
			'/signup'
		end
	end
end
