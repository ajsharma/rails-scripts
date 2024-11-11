# frozen_string_literal: true

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
          downcase
        end
      end
    end
  end
end
