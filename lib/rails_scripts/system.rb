module RailsScripts
	class System
		class << self
			def call(*args)
				if RailsScripts.configuration.verbose?
					puts *args
				end

				Kernel.system *args
			end

			def echo(message, color: :default, background: :default)
				require 'colorized_string'


				puts ColorizedString.new(message).colorize(color: color, background: background)
			end
		end
	end
end
