#!/usr/bin/env ruby
#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#


#
# General Compilation Pipeline: 
#
# Parse the dog code into an AST (called a bark)
# => bark = Dog::Parser.parse(dog_code)
#
# Compute the AST into a vm byte code (called bite code)
# => bite = Dog::Compiler.compile(bark)
#
# Execute the byte code. This may save state as an execution graph (called a track)
# => Dog::Runtime.run(bite)
#


#ENV['BUNDLE_GEMFILE'] = File.expand_path('../../Gemfile', __FILE__)

require 'rubygems'
#require 'bundler/setup'
require File.join(File.dirname(__FILE__), '../lib/dog/version.rb')


class Command
  class << self
    
    attr_accessor :registered_commands
    
    def register(command)
      self.registered_commands ||= {}
      self.registered_commands[command.new.name] = command.new
    end
    
    def find_command_by_name(name)
      object = self.registered_commands[name]
      if object then
        object
      else
        nil
      end
    end
    
    def run(args)
      self.new.run(args)
    end
    
  end
  
  def name
    self.class.name.downcase
  end
  
  def usage
    puts "Dog #{Dog::VERSION::STRING} (#{Dog::VERSION::CODENAME})"
  end
  
  def run(args)
    command = self.class.find_command_by_name((args.first || "").downcase)
    
    if command then
      unless command.class == Help then
        require File.join(File.dirname(__FILE__), '../lib/dog.rb')
      end
      
      args.shift
      command.run(args)
    else
      Help.new.usage
    end
  end
end

class Init < Command
  Command.register(self)
  
  def description
    "Create a new Dog application directory"
  end
  
  def usage
    super
    puts
    puts "Usage: dog init [DIRECTORY]"
    puts
    puts "  WARNING: This command is not yet implemented."
    puts
  end
  
  def run(args)
    usage
  end  
end

class Compile < Command
  Command.register(self)
  
  def description
    "Compile a Dog source file or application"
  end
  
  def usage
    super
    puts
    puts "Usage: dog compile [FILE.dog]"
    puts
  end
  
  def run(args)
    source_filename = args.first
    source_code = File.open(source_filename).read
    
    bark = Dog::Parser.parse(source_code)
    bite = Dog::Compiler.compile(bark)
    
    # TODO - Handle error reporting here...
    begin
      bite_code_filename = File.basename(source_filename, ".dog") + ".bite"
      bite_code_file = File.open(bite_code_filename, "w")
      bite_code_file.write(Base64.encode64(bite.to_hash.inspect))
      bite_code_file.close
    rescue Dog::CompilationError => error
      raise error
    rescue Dog::ParseError => error
      raise error
    end
  end
end

class Run < Command
  Command.register(self)
  
  def description
    "Execute a Dog source file or application"
  end
  
  def usage
    super
    puts
    puts "Usage: dog run [FILE.bite]"
    puts
  end
  
  def run(args)
    
  end
end

class Shell < Command
  Command.register(self)
  
  def description
    "Start a shell session with a running Dog application"
  end
  
  def usage
    super
    puts
    puts "Usage: dog shell [URL]"
    puts
    puts "  WARNING: This command is not yet implemented."
    puts
  end
  
  def run(args)
    usage
  end
end

class Help < Command
  Command.register(self)
  
  def description
    "Show the help page for a command"
  end
  
  def usage
    super
    puts
    puts "Usage: dog COMMAND [command-specific-arguments]"
    puts
    puts "List of commands, type \"dog help COMMAND\" for more details:"
    puts
    
    max_length = 0
    
    for key, value in Command.registered_commands do
      max_length = [max_length, key.length].max
    end
    
    for key, value in Command.registered_commands do
      remaining = max_length - key.length
      remaining += 2
      
      print "  #{key}"
      remaining.times { print " " }
      print "# "
      print value.description
      print "\n"
    end
    
    puts
    
  end
  
  def run(args)
    command = Command.find_command_by_name((args.first || "").downcase)
    
    if command then
      command.usage
    else
      self.usage
    end
  end
end


# All of that for this:
Command.run(ARGV.clone)

