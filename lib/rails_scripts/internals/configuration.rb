module RailsScripts
	module Internals
		class Configuration

			attr_accessor(
				:git_trunk_branch_name,
				:verbose
			)

			def initialize
				load_defaults
			end

			def verbose?
				!!verbose
			end

			private

			def load_defaults
				self.git_trunk_branch_name = 'master'
				self.verbose = false
			end
		end
	end
end
