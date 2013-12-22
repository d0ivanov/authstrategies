module Authstrategies
	class Warden::SessionSerializer
		def serialize(user)
			user.id
		end

		def deserialize
			User.find(id)
		end
	end
end
