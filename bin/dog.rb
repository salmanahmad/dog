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
require 'pp'
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
  
  def dog_version_string
    "Dog #{Dog::VERSION::STRING} (Codename: #{Dog::VERSION::CODENAME})"
  end
  
  def name
    self.class.name.downcase
  end
  
  def usage
    puts dog_version_string
  end
  
  def run(args)
    command = self.class.find_command_by_name((args.first || "").downcase)
    
    if command then
      unless [Help, Version].include? command.class then
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

class Parse < Command
  Command.register(self)
  
  def description
    "Parse a Dog source file and return the resulting syntax tree."
  end
  
  def usage
    super
    puts
    puts "Usage: dog parse [FILE.dog]"
    puts
  end
  
  def run(args)
    source_filename = args.first
    source_code = ""
    source_filename += ".dog"
    
    begin
      source_code = File.open(source_filename).read
    rescue
      puts "Error: Could not read '#{source_filename}'"
      exit
    end
    
    begin
      parse_tree = Dog::Parser.parse(source_code, source_filename)
      pp parse_tree
    rescue Dog::ParseError => error
      puts error
    end
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
    
    if args.first == "-asm" then
      dump = true
      args.shift
    else
      dump = false
    end
    
    source_filename = args.first
    source_code = ""
    source_filename += ".dog"
    
    begin
      source_code = File.open(source_filename).read
    rescue
      puts "Error: Could not read '#{source_filename}'"
      exit
    end
    
    begin
      # TODO - Update this to handle multiple files
      
      bark = Dog::Parser.parse(source_code, source_filename)
      bundle = Dog::Compiler.compile([[bark, source_filename]])
      
      bundle_filename = File.basename(source_filename, ".dog") + ".bundle"
      bundle_file = File.open(bundle_filename, "w")
      
      bundle_file.write(JSON.dump(bundle.to_hash))
      
      bundle_file.close
      
      puts bundle.dump_bytecode if dump
      
      return true
    rescue Dog::CompilationError => error
      puts error
    rescue Dog::ParseError => error
      puts error
    rescue Exception => error
      puts "Error: An unknown compilation error occured: "
      puts
      puts error
      raise error
    end
    
    return false
  end
end

class Run < Command
  Command.register(self)
  
  def description
    "Execute a Dog source file or application"
  end
  
  def parse_options(args)
    args = args.clone
    args.shift
    
    options = {
      "config_file" => "",
      "config" => {}
    }
    
    i = 0
    while i < args.length do
      arg = args[i]
      next_arg = args[i + 1]
      
      if arg == "-c" then
        options["config_file"] = next_arg
      elsif arg == "-d"
        options["config"]["database"] = next_arg
      elsif arg == "-u"
        options["config"]["dog_prefix"] = next_arg
      elsif arg == "-p"
        options["config"]["port"] = next_arg.to_i
      end
      
      i = i + 2
    end
    
    return options
  end
  
  def usage
    super
    puts
    puts "Usage: dog run [FILE.bite] [options]"
    puts
    puts "  Execute the Dog bite code in FILE.bite. If no file is provided, Dog will first check 'config.json'"
    puts "  for the name of the main application file in the current directory. If 'config.json' does not exist"
    puts "  then Dog will default to the first .bite file it finds in the current directory. If there is no .bite"
    puts "  file Dog will return an error."
    puts
    puts "Options include: "
    puts "  -c config_file      # Specify the application configuration file. Default: config.json."
    puts "  -d database_name    # Specify the MongoDB database name. Default: the same name as the bite code file."
    puts "  -u url_prefix       # Specify the URL prefix to mount Dog. Default: /dog"
    puts "  -p port             # Specify the port to run Dog's server. Default: 4242."
    puts
  end
  
  def run(args)
    begin
      bundle_filename = args.first + ".bundle"
      Dog::Runtime.run_file(bundle_filename, parse_options(args))
    rescue Exception => e
      raise e
      puts e
    end
  end
end

class Start < Command
  Command.register(self)
  
  def description
    "Compile and execute a dog program and clears the database if needed"
  end
  
  def usage
    super
    puts
    puts "Usage: dog start [FILE.dog] [options]"
    puts
    puts "  TODO"
    puts
  end
  
  def run(args)
    source_filename = args.first + ".dog"
    bundle_filename = args.first + ".bundle"
    
    if File.exists?(source_filename) && File.exist?(bundle_filename) && (File.mtime(source_filename) > File.mtime(bundle_filename)) then
      restart_command = Restart.new
      restart_command.run(args)
    else
      run_command = Run.new
      run_command.run(args)
    end
  end
end

class Restart < Command
  Command.register(self)
  
  def description
    "Compile and execute a dog program after clearing the database."
  end
  
  def usage
    super
    puts
    puts "Usage: dog restart [FILE.dog] [options]"
    puts
    puts "  Compile a Dog program and execute the resulting bite code. If this program has already been executed"
    puts "  previously, 'restart' will clear that database so the code is run from a 'clean slate'. This command "
    puts "  takes the same options as the 'run' command."
    puts
  end
  
  def run(args)
    bundle_filename = args.first + ".bundle"
    
    compile_command = Compile.new
    unless compile_command.run(args) then
      exit
    end
    
    run_command = Run.new
    options = run_command.parse_options(args)
    options["database"] = {
      "reset" => true
    }
    
    begin
      Dog::Runtime.run_file(bundle_filename, options)
    rescue Exception => e
      puts e
      raise e
    end
  end
end

class Reset < Command
  Command.register(self)
  
  def description
    "Clears the database associated with the dog application."
  end
  
  def usage
    super
    puts
    puts "Usage: dog reset [FILE] [options]"
    puts
    puts "  Clears the database associated with the dog application. Takes the same options as 'run'."
    puts
  end

  def run(args)
    bundle_filename = args.first + ".bundle"
    json = File.open(bundle_filename).read
    hash = JSON.load(json)
    bundle = ::Dog::Bundle.from_hash(hash)
    
    
    run_command = Run.new
    
    options = run_command.parse_options(args)
    options["database"] = {
      "reset" => true
    }
    
    ::Dog::Runtime.initialize(bundle, bundle_filename, options)
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


class Version < Command
  Command.register(self)
  
  def description
    "Show the dog version"
  end
  
  def usage
    super
    puts
    puts "Usage: dog version"
    puts
    puts "  #{description}"
    puts
  end
  
  def run(args)
    puts dog_version_string
  end
end

# All of that for this:
Command.run(ARGV.clone)

