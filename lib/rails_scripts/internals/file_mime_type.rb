module RailsScripts
  module Internals
    # Utility class to make it easier to create files that don't exist
    class FileMimeType
      class << self
        def find_or_create(pathname, template)
          raise ArgumentError, 'pathname is required' unless pathname
          raise ArgumentError, 'template is required' unless template

          return pathname if pathname.exist?
          # raise "Cannot proceed: [#{pathname}] is not a file" unless pathname.file?

          # Create the parent folder
          pathname.dirname.mkpath

          # Write a placeholder template
          pathname.write(template)

          pathname
        end
      end
    end
  end
end
