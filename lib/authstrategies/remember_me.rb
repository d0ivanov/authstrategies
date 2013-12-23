module Authstrategies
	class RememberMeStrategy < Warden::Strategies::Base
		def valid?
			!!(env['authstrategies.remember'])
		end

		def authenticate!
			user = User.find_by_remember_me_token(env['authstrategies.remember']['token'])
			if user && user.remember_me
				success!(user)
			else
				env.delete('authstrategies.remember')
				fail!('')
			end
		end
	end
end
