#!/usr/bin/env ruby
#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

# TODO compile option that just outputs a compiled .rb file

ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

require 'rubygems'
require 'bundler/setup'

script_file = ARGV.pop

if script_file.nil? then
  puts "error: no input file provided"
  exit
end

script_file = File.expand_path(script_file)
$0 = script_file

# Evaluate the script!
