
module RailsScripts
  module Internals
  	class RailsConventions
  		class << self
	  		def pathname_to_pascal_case(pathname)
					pathname.split('_').collect(&:capitalize).join
				end
			end
		end
	end
end
