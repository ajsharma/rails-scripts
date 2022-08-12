# frozen_string_literal: true

require 'open3'

module RailsScripts
  # Proxy to system's Kernel
  class System
    # Provides configuration of the RailsScripts's system class.
    class Configuration
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
        self.verbose = false
      end
    end

    class << self
      def configuration
        @configuration ||= System::Configuration.new
      end

      def configure
        yield(configuration)
      end

      def call(*args)
        puts(*args) if RailsScripts::System.configuration.verbose?

        Kernel.system(*args)
      end

      def stream(*args, &block)
        puts(*args) if RailsScripts::System.configuration.verbose?

        Open3.popen3(*args, &block)
      end

      def echo(message, color: :default, background: :default)
        require 'colorized_string'

        puts ColorizedString.new(message).colorize(color: color, background: background)
      end
    end
  end
end
