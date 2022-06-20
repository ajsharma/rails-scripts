module RailsScripts
	module Commands
		class RspecChangedSpecsCommand
			class << self
				# Runs RSpec against changed specs
				# git diff --diff-filter=d --name-only $(git merge-base main HEAD) | grep -e "._spec.rb$" | xargs -t bin/rspec -fd
				def run
					RailsScripts::System.call <<~SH
						git diff --diff-filter=d --name-only $(git merge-base #{RailsScripts.configuration.git_trunk_branch_name} HEAD) | grep -e "._spec.rb$" | xargs -t bin/rspec -fd
					SH
				end
			end
		end
	end
end
