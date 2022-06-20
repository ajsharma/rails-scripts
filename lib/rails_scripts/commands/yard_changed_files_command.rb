module RailsScripts
	module Commands
		class YardChangedFilesCommand
			class << self
				# Regenerates yardocs
				# git diff --name-only $(git merge-base main HEAD) | grep -e ".rb$" | xargs -t bundle exec bin/yard doc --no-cache --fail-on-warning
				def run
					RailsScripts::System.call <<~SH
						git diff --name-only $(git merge-base #{RailsScripts.configuration.git_trunk_branch_name} HEAD) | grep -e ".rb$" | xargs -t bundle exec bin/yard doc --no-cache --fail-on-warning
					SH
				end
			end
		end
	end
end
