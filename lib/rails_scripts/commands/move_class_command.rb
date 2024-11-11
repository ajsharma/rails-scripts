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
          # Copy from -> to
          prefix, from_file_path = guess_existing_file_path(from)
          to_file_path = guess_destination_file_path(prefix, to)

          # TODO: remove, debugging only
          puts from_file_path
          puts to_file_path

          FileUtils.cp from_file_path, to_file_path
          # TODO: need to update new file's class name with the new name
          rewrite_file(to_file_path, "class #{from}", "class #{to}")

          # Replace body of from with deprecated template
          File.write(from_file_path, <<~TEMPLATE)
            # @deprecated Use #{to} instead.
            class #{from} < #{to}; end
          TEMPLATE

          # Copy rspec from -> rspec to
          from_rspec_file_path = Internals::RspecFilePathGuesser.guess(from_file_path)
          if from_rspec_file_path && File.exist?(from_rspec_file_path)
            to_rspec_file_path = Internals::RspecFilePathGuesser.guess(to_file_path)

            FileUtils.cp from_rspec_file_path, to_rspec_file_path
            rewrite_file(to_rspec_file_path, "RSpec.describe #{from}", "RSpec.describe #{to}")
          end

          # TODO: git commands, may need to do this earlier.
          # git add #{from_file_path}
          # git add #{to_file_path}
          # git add #{to_rspec_file_path}
        end

        private

        def rewrite_file(file_path, pattern, replacement)
          content = File.read(file_path)
          File.write(file_path, content.sub( pattern, replacement))
        end

        def guess_existing_file_path(class_name)
          end_of_file_name = Internals::RailsConventions.class_to_pathname(class_name)
          # Need to deal with the dynamic app, job, lib, etc. folder
          matches = Dir["./**/#{end_of_file_name}.rb"]

          if matches.size > 1
            raise RuntimeError, <<~ERROR_MESSAGE
              Found too many possible file matches for #{class_name}

              Matches found:
              #{matches.join('\n')}
            ERROR_MESSAGE
          end

          return matches.first.gsub("#{end_of_file_name}.rb", ""), matches.first
        end

        def guess_destination_file_path(prefix, class_name)
          end_of_file_name = Internals::RailsConventions.class_to_pathname(class_name)
          guess = "#{prefix}#{end_of_file_name}.rb"
          matches = Dir[guess]

          if matches.size > 0
            raise ArgumentError, <<~ERROR_MESSAGE
              Cannot write to #{matches[0]} for #{class_name}

              A file at #{matches[0]} already exists.
            ERROR_MESSAGE
          end

          return guess
        end
      end
    end
  end
end
