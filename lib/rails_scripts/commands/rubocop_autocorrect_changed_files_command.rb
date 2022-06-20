# frozen_string_literal: true

module RailsScripts
  module Commands
    # Runs Rubocop against files changed in git diff
    #
    # Warning: Will change files!
    class RubocopAutocorrectChangedFilesCommand
      class << self
        # Runs rubocop autocorrect on all ruby files changed
        #
        # git diff --diff-filter=d --name-only $(git merge-base main HEAD) | grep -e ".rb$" -e ".rake$" | xargs -t bundle exec rubocop --enable-pending-cops --autocorrect-all --display-style-guide --force-exclusion
        def run
          RailsScripts::System.call <<~SH
            git diff --diff-filter=d --name-only $(git merge-base #{RailsScripts.configuration.git_trunk_branch_name} HEAD) | grep -e ".rb$" -e ".rake$" | xargs -t bundle exec rubocop --enable-pending-cops --autocorrect-all --display-style-guide --force-exclusion
          SH
        end
      end
    end
  end
end
