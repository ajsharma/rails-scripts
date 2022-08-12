# frozen_string_literal: true

require 'pathname'

module RailsScripts
  module Internals
    # Guesses what the appropriate spec file is (if any) for any Rails application file.
    class RspecFilePathGuesser
      class << self
        def guess(application_file_path)
          new.guess(application_file_path)
        end

        # Returns list of guesses, could return an empty list
        def guesses(application_file_paths)
          application_file_paths.map { |application_file_path| guess(application_file_path) }.compact
        end
      end

      # Returns best guess of where the spec file _should_ be. Does not guarantee that the file exists.
      #
      # @return [String, null] String with guess or null if the guess is that there is no appropriate spec file
      def guess(application_file_path)
        raise ArgumentError, 'application_file_path is required' unless application_file_path

        reset_errors

        guess_pathname = RailsPathname.new(application_file_path.chomp)

        # If it's already a spec, it's good.
        return guess_pathname if guess_pathname.spec_file?

        # Non-specs in spec folder can be ignored, they're likely support files
        if guess_pathname.in_spec_folder?
          @errors[guess_pathname] = 'Not a spec file, but in spec folder.'
          return nil
        end

        # Ignore things in the root folder, we don't test those.
        if guess_pathname.in_root_folder?
          @errors[guess_pathname] = 'In root folder'
          return nil
        end

        return guess_pathname.move_from_app_to_spec_folder.convert_to_spec_file if guess_pathname.in_app_folder?

        return guess_pathname.move_from_lib_to_spec_folder.convert_to_spec_file if guess_pathname.in_lib_folder?

        # Should always have a guess. Unless the file is outside of Rails folder or other oddity
        raise "Could not guess spec file for #{application_file_path}"
      end

      private

      attr_reader :errors

      def reset_errors
        @errors = Hash.new { |hash, key| hash[key] = [] }
      end

      # Represents a file within the Rails codebase/folder
      class RailsPathname < Pathname
        def spec_file?
          end_with?(SPEC_FILE_SUFFIX)
        end

        def in_root_folder?
          dir, _base = split
          dir.to_s == '.'
        end

        def in_app_folder?
          start_with?(APP_FOLDER_PREFIX)
        end

        def in_lib_folder?
          start_with?(LIB_FOLDER_PREFIX)
        end

        def in_spec_folder?
          start_with?(SPEC_FOLDER_PREFIX)
        end

        def move_from_app_to_spec_folder
          sub(APP_FOLDER_PREFIX, SPEC_FOLDER_PREFIX)
        end

        def move_from_lib_to_spec_folder
          sub(LIB_FOLDER_PREFIX, SPEC_FOLDER_PREFIX)
        end

        # convert a file from .rb to _spec.rb
        def convert_to_spec_file
          sub_last(RUBY_FILE_SUFFIX, SPEC_FILE_SUFFIX)
        end

        private

        APP_FOLDER_PREFIX = 'app/'
        LIB_FOLDER_PREFIX = 'lib/'
        SPEC_FOLDER_PREFIX = 'spec/'

        RUBY_FILE_SUFFIX = '.rb'
        SPEC_FILE_SUFFIX = '_spec.rb'

        def start_with?(prefix)
          to_s.start_with?(prefix)
        end

        def end_with?(suffix)
          to_s.end_with?(suffix)
        end

        def sub(pattern, replacement)
          self.class.new(to_s.sub(pattern, replacement))
        end

        def sub_last(pattern, replacement)
          # https://stackoverflow.com/questions/3185144/how-to-replace-the-last-occurrence-of-a-substring-in-ruby
          sub(/.*\K#{pattern}/, replacement)
        end
      end
    end
  end
end
