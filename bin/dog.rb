#!/usr/bin/env ruby
#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

#ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

require 'rubygems'
require 'bundler/setup'
require File.join(File.dirname(__FILE__), '../lib/dog.rb')

if ARGV.empty? then
  puts "error: no input file provided"
  exit
end

# TODO - Fix this hack for TextMate Ruby module
if ARGV.first == "-KU" then
  dog_code = File.open(ARGV.last).read
else
  # Read the dog code from the file
  dog_code = ARGF.read
end


# Parse the dog code into an AST (called a bark)
bark = Dog::Parser.parse(dog_code)

# Compute the AST into a vm byte code (called bite code)
bite = Dog::Compiler.compile(bark)

# Execute the byte code. This may save state 
# as an execution graph (called a track)
Dog::Runtime.run(bite)

