# frozen_string_literal: true

module RailsScripts
  module Commands
    # Writes a basic spec file for any changed files
    class RspecWriteSpecsCommand
      class << self
        # Runs RSpec against changed specs
        #
        # git diff --diff-filter=d --name-only $(git merge-base main HEAD) | grep -e "._spec.rb$" | xargs -t bin/rspec -fd
        def run
          git_changed_files = []
          RailsScripts::System.stream <<~SH do |stdout, stderr, status, thread|
            git diff --name-only $(git merge-base #{RailsScripts.configuration.git_trunk_branch_name} HEAD)
          SH
            while stderr_line = stderr.gets do
              git_changed_files << stderr_line
            end
          end

          puts "Found changes:"
          puts git_changed_files

          impacted_spec_files = Internals::RspecFilePathGuesser.guesses(git_changed_files)

          puts "Rspec files"
          puts impacted_spec_files

          # TODO: if a spec_file _did_ exist, but no longer does, we should not re-create it
          # Example, renamed a spec file

          # QUESTION: what if a file was deleted, and didn't have an equivalent test file?

          found_spec_files = Internals::FileMaker.find_or_create_all(impacted_spec_files)

          RailsScripts::System.call <<~SH
            bin/rspec -fd #{found_spec_files.join(' ')}
          SH
        end
      end
    end
  end
end
