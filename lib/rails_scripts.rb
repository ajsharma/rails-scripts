# frozen_string_literal: true

# Collection of runnable commands to help developers deliver Rails
# software faster
module RailsScripts
  class << self
    attr_writer(
      :configuration
    )

    def configuration
      @configuration ||= Internals::Configuration.new
    end

    def configure
      yield(configuration)
    end
  end
end
