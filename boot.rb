#!/bin/rb
# frozen_string_literal: true

# Bootstraps the scripts, ensures things like ENV variables are loaded.

# Initial wiring, just to make life simpler
require 'dotenv/load'

# Allow us to load files by class name rather than
# explicit requires
require 'zeitwerk'
loader = Zeitwerk::Loader.new
loader.push_dir("#{__dir__}/lib")
loader.setup # ready!

require_relative 'lib/rails_scripts'

RailsScripts.configure do |config|
  config.git_trunk_branch_name = ENV.fetch('RAILS_SCRIPTS__GIT_TRUNK_BRANCH_NAME', nil)
  config.verbose = ENV.fetch('RAILS_SCRIPTS__VERBOSE', nil)
end
