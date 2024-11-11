# move ConnectionEndpointImportInvokeJob, PaymentsIngestion::ConnectionEndpointImportInvokeJob

def move(origin_klass, destination_klass)

end

# frozen_string_literal: true

module RailsScripts
  module Commands
    # Copy the contents of a class from old name to new name.
    # C the RSpec files
    class MoveClassCommand
      class << self
        # Runs
        def run(from:, to:)
					# Copy from -> to
					from_file_path = find_file_path(from)
					destination_file_path = find_file_for(origin_klass)

					# Copy rspec from -> rspec to

					# Replace body of from with deprecated template
        end
      end
    end
  end
end
