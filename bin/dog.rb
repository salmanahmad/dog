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


command = ARGV.first || ""

case command.downcase
when "init"

when "shell"
  
when "compile"

when "run"
  
when "help"
  
else
  puts "Dog #{Dog::VERSION::STRING} (#{Dog::VERSION::CODENAME})"
  puts
  puts "Usage: dog COMMAND [command-specific-arguments]"
  puts
  puts "List of commands, type \"dog help COMMAND\" for more details:"
  puts
  puts "  init     # Create a new Dog application directory"
  puts "  compile  # Compile a Dog source file or application"
  puts "  run      # Execute a Dog source file or application"
  puts "  shell    # Start a shell session with a running Dog application"
  puts
end
  



__END__


if ARGV.empty? then
  puts "error: no input file provided"
  exit
end

dog_file = ARGV.last
dog_code = File.open(dog_file).read
bite_code_filename = File.basename(dog_file, ".dog") + ".bite"

# TODO - Fix this hack for TextMate Ruby module
#if ARGV.first == "-KU" then
#  dog_code = File.open(ARGV.last).read
#else
#  # Read the dog code from the file
#  dog_code = ARGF.read
#end

# Parse the dog code into an AST (called a bark)
bark = Dog::Parser.parse(dog_code)

# Compute the AST into a vm byte code (called bite code)
bite = Dog::Compiler.compile(bark)

bite_code_file = File.open(bite_code_filename, "w")
bite_code_file.write(Base64.encode64(bite.to_hash.inspect))

# Execute the byte code. This may save state 
# as an execution graph (called a track)
#Dog::Runtime.run(bite)

