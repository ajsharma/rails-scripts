module RailsScripts
  class << self
    attr_writer(
    	:configuration,
  	)

		def configuration
	    @configuration ||= Internals::Configuration.new
	  end

	  def configure
	    yield(configuration)
	  end
	end
end
