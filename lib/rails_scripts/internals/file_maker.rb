# frozen_string_literal: true

require 'fileutils'

module RailsScripts
  module Internals
    # Utility class to make it easier to create files that don't exist
    class FileMaker
      class << self
        def find_or_create(pathname)
          raise ArgumentError, 'pathname is required' unless pathname

          return pathname if pathname.exist?
          # raise "Cannot proceed: [#{pathname}] is not a file" unless pathname.file?

          # Create the parent folder
          pathname.dirname.mkpath

          # Write a placeholder template
          pathname.write(<<~TEMPLATE)
            RSpec.describe 'TODO' do
            end
          TEMPLATE

          pathname
        end

        def find_or_create_all(pathnames)
          pathnames.map do |pathname|
            find_or_create(pathname)
          end
        end
      end
    end
  end
end
