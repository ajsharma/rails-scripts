# frozen_string_literal: true

module RailsScripts
  # Proxy to system's Kernel
  class System
    class << self
      def call(*args)
        puts(*args) if RailsScripts.configuration.verbose?

        Kernel.system(*args)
      end

      def echo(message, color: :default, background: :default)
        require 'colorized_string'

        puts ColorizedString.new(message).colorize(color: color, background: background)
      end
    end
  end
end
