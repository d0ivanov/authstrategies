module Authstrategies
	module Strategies

		class PasswordStrategy < Warden::Strategies::Base
			def valid?
				!!(request["email"] && request["password"])
			end

			def authenticate!
				user = User.find_by_email(request["email"])
				if user && user.authenticate(request)
					success!(user)
				else
					fail!("Invalid username or password")
				end
			end
		end

	end
end
