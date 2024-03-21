# frozen_string_literal: true

module RailsScripts
  module Commands
    # Identify changes javascript files for Yarn
    class YarnChangedFilesCommand
      class << self
        # Regenerates yardocs
        #
        # git diff --name-only $(git merge-base main HEAD) | grep -e ".rb$" | xargs -t bundle exec bin/yard doc --no-cache --fail-on-warning
        def run
          RailsScripts::System.call <<~SH
            git diff --name-only $(git merge-base #{RailsScripts.configuration.git_trunk_branch_name} HEAD) | grep -e ".js$" -e ".jsx$" -e ".ts$" -e ".tsx$" | xargs -t bin/yarn eslint --fix
          SH
        end
      end
    end
  end
end
