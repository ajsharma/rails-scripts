# frozen_string_literal: true

module RailsScripts
  module Internals
    # Global configuration object for the RailsScripts module
    #
    # See attributes for configurable values
    class Configuration
      # Name of central git branch, usually 'main', or 'master'
      attr_accessor(:git_trunk_branch_name)

      # Set to `true` to emit commands and additional logs
      attr_accessor(:verbose)

      def initialize
        load_defaults
      end

      def verbose?
        !!verbose
      end

      private

      def load_defaults
        self.git_trunk_branch_name = 'main'
        self.verbose = false
      end
    end
  end
end
