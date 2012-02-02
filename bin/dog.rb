#!/usr/bin/env ruby
#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

require 'rubygems'
require 'bundler/setup'
require File.join(File.dirname(__FILE__), '../lib/dog.rb')

if ARGV.empty? then
  puts "error: no input file provided"
  exit
end

# Read the dog code from the file
dog_code = ARGF.read

# Parse the dog code into an AST (called a bark)
dog_bark = Dog::Parser.parse(dog_code).to_bark

# Compute the AST into a state machine (called a collar)
dog_collar = Dog::Compiler.compile(dog_barks)

# Execute the state machine. This may save state 
# as an execution graph (called a leash)
Dog::Runtime.run(dog_collar)

