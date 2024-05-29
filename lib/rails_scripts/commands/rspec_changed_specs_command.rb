# frozen_string_literal: true

module RailsScripts
  module Commands
    # Runs RSpec against files changed in git diff
    class RspecChangedSpecsCommand
      class << self
        # Runs RSpec against changed specs
        #
        # git diff --relative --diff-filter=d --name-only $(git merge-base main HEAD) | grep -e "._spec.rb$" | xargs -t bin/rspec -fd
        def run
          git_changed_files = []
          RailsScripts::System.stream <<~SH do |_stdout, stderr, _status, _thread|
            git diff --relative --name-only $(git merge-base #{RailsScripts.configuration.git_trunk_branch_name} HEAD)
          SH
            while (stderr_line = stderr.gets)
              git_changed_files << stderr_line
            end
          end

          Internals::RspecFilePathGuesser.guesses(git_changed_files).each do |spec_file_guess|
            # 2022-12-24 Some problem here with trailing character [0m
            System.echo spec_file_guess.to_s
          end
        end
      end
    end
  end
end
