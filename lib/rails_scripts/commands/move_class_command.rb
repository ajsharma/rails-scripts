# frozen_string_literal: true

require 'pathname'
require 'fileutils'

module RailsScripts
  module Commands
    # Copy the contents of a class from old name to new name.
    #
    # The goal is to make the migration easier and let linters deal with the clean up.
    class MoveClassCommand
      class << self
        # @param [String] from class name
        # @param [String] to class name
        def run(from:, to:)
          # Validate inputs
          from_file_name_guess = Internals::RailsConventions.class_to_pathname(from)
          from_file_path = find_existing_file(from_file_name_guess)

          application_layer_folder = from_file_path.gsub("#{from_file_name_guess}", "") # gives ./app/model/, ./app/job/, etc.
          to_file_name_guess = Internals::RailsConventions.class_to_pathname(to)

          to_file_path = "#{application_layer_folder}#{to_file_name_guess}"
          ensure_writable_file_path(to_file_path)

          # replace all existing references
          RailsScripts::System.call <<~SH
            git grep -l -e '#{from}' --and --not -e "::#{from}" | xargs sed -i '' -e 's/#{from}/#{to}/g'
          SH

          RailsScripts::System.call <<~SH
            git commit --all --message="Updates references to #{from} to #{to}"
          SH

          # Copy from -> to
          Internals::FileMaker.copy(from_file_path, to_file_path)

          RailsScripts::System.call <<~SH
            git add #{to_file_path}
          SH

          RailsScripts::System.call <<~SH
            git commit --message="Cloning #{from} to #{to}"
          SH

          # Replace body of from with deprecated template
          File.write(from_file_path, <<~TEMPLATE)
            # @deprecated Use #{to} instead.
            class #{from} < #{to}; end
          TEMPLATE

          RailsScripts::System.call <<~SH
            git add #{from_file_path}
          SH

          RailsScripts::System.call <<~SH
            git commit --message="Deprecating #{from}"
          SH

          # Copy rspec from (if exists) -> rspec to
          from_rspec_file_path = Internals::RspecFilePathGuesser.guess(from_file_path)
          if from_rspec_file_path && File.exist?(from_rspec_file_path)
            to_rspec_file_path = Internals::RspecFilePathGuesser.guess(to_file_path)

            Internals::FileMaker.copy(from_rspec_file_path, to_rspec_file_path)

            RailsScripts::System.call <<~SH
              git add #{to_rspec_file_path}
            SH

            # undo the changes to the initial Rspec file
            RailsScripts::System.call <<~SH
              git checkout master #{from_rspec_file_path}
            SH

            RailsScripts::System.call <<~SH
              git commit --message="Cloning RSpec tests"
            SH
          end

          # Clone CODEOWNERS entry

          codeowners_file_path = '../.github/CODEOWNERS'

          # Read the existing content of the file
          codeowner_lines = File.readlines(codeowners_file_path)

          # Open the file for writing with the modifications
          File.open(codeowners_file_path, 'w') do |file|
            codeowner_lines.each do |line|
              file.puts(line)
              # Check if the line contains 'apple.rb'
              if line.include?(from_file_name_guess)
                new_line = line.sub(from_file_name_guess, to_file_name_guess)
                file.puts(new_line)
              end
            end
          end

          RailsScripts::System.call <<~SH
            git add #{codeowners_file_path}
          SH

          RailsScripts::System.call <<~SH
            git commit --message="Updating CODEOWNERS file"
          SH
        end

        private

        def find_existing_file(end_of_file_name)
          # Need to deal with the dynamic app, job, lib, etc. folder
          matches = Dir["./*/*/#{end_of_file_name}"]

          if matches.size > 1
            raise RuntimeError, <<~ERROR_MESSAGE
              Found too many possible file matches for #{end_of_file_name}

              Matches found:
              #{matches.join('\n')}
            ERROR_MESSAGE
          end

          return matches.first
        end

        def ensure_writable_file_path(path)
          matches = Dir[path]

          if matches.size > 0
            raise ArgumentError, <<~ERROR_MESSAGE
              Cannot write to #{matches[0]} for #{path}

              A file at #{matches[0]} already exists.
            ERROR_MESSAGE
          end

          return true
        end
      end
    end
  end
end
