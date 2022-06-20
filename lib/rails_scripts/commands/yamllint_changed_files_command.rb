module RailsScripts
	module Commands
		class YamllintChangedFilesCommand
			class << self
				# Runs yamllint on all yaml/yml files changed
				# git diff --diff-filter=d --name-only $(git merge-base main HEAD) | grep -e ".yml$" -e ".yaml$" | xargs -t yamllint
				def run
					RailsScripts::System.call <<~SH
						git diff --diff-filter=d --name-only $(git merge-base #{RailsScripts.configuration.git_trunk_branch_name} HEAD) | grep -e ".yml$" -e ".yaml$" | xargs -t yamllint
					SH
				end
			end
		end
	end
end
