#!/bin/rb

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
