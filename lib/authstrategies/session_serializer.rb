module Authstrategies
	private
		class Warden::SessionSerializer
			def serialize(user)
				user.id
			end

			def deserialize(id)
				User.find(id)
			end
		end
end
