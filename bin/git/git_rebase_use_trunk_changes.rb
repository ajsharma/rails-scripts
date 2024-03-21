#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative '../../boot'

# Git rebase, use my branch code to fix conflicts
RailsScripts::System.call <<~SH
  git rebase -Xours #{RailsScripts.configuration.git_trunk_branch_name}
SH
