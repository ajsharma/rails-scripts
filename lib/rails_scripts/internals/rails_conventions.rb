# frozen_string_literal: true

require 'active_support/inflector'
require 'pathname'

module RailsScripts
  module Internals
    class RailsConventions
      class << self
        # Convert Something::MyClass to something/my_class, does _not_ include `app` or `job` prefix
        def class_to_pathname(class_name)
          class_name.gsub(/::/, '/').
          gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
          gsub(/([a-z\d])([A-Z])/,'\1_\2').
          tr("-", "_").
          downcase + ".rb"
        end

        def pathname_to_class(path)
          path = path.chomp
          path = Pathname.new(path).cleanpath.to_s
          path = path.sub(%r{^.*?(app|lib)/}, '')      # Remove up to app/ or lib/
          path = path.sub(/\_spec.rb$/, '')            # Remove _spec.rb extension
          path = path.sub(/\.rb$/, '')                 # Remove .rb extension

          segments = path.split('/')

          # Special case: controller, job, mailer, etc.
          segments.shift

          # Camelize path parts
          segments = segments.map { |seg| seg.camelize }

          full_class = segments.join('::')
          full_class
        end
      end
    end
  end
end
