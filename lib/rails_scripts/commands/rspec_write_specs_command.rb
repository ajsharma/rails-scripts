# frozen_string_literal: true

module RailsScripts
  module Commands
    # Writes a basic spec file for any changed files
    class RspecWriteSpecsCommand
      class << self
        # Looks for specs that should exist, then creates missing ones, then runs test suite
        def run(arguments_array)
          git_changed_files = []
          RailsScripts::System.stream <<~SH do |_stdout, stderr, _status, _thread|
            git diff --relative --name-only $(git merge-base #{RailsScripts.configuration.git_trunk_branch_name} HEAD)
          SH
            while (stderr_line = stderr.gets)
              git_changed_files << stderr_line
            end
          end

          impacted_spec_files = Internals::RspecFilePathGuesser.guesses(git_changed_files)

          # TODO: if a spec_file _did_ exist, but no longer does, we should not re-create it
          # Example, renamed a spec file

          # QUESTION: what if a file was deleted, and didn't have an equivalent test file?

          found_spec_files = impacted_spec_files.map do |impacted_spec_file|
            Internals::FileMaker.find_or_create(impacted_spec_file, <<~TEMPLATE)
              RSpec.describe 'TODO' do
                pending "add some examples to (or delete) \#{__FILE__}"
              end
            TEMPLATE
          end

          RailsScripts::System.call <<~SH
            bin/rspec -fd #{arguments_array.join(' ')} #{found_spec_files.join(' ')}
          SH
        end
      end
    end
  end
end
