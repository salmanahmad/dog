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
require 'readline'
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
    source_code = ""
    
    begin
      source_code = File.open(source_filename).read
    rescue
      puts "Error: Could not read '#{source_filename}'"
      exit
    end
    
    begin
      bark = Dog::Parser.parse(source_code, source_filename)
      bite = Dog::Compiler.compile(bark, source_filename)
      
      bite_code_filename = File.basename(source_filename, ".dog") + ".bite"
      bite_code_file = File.open(bite_code_filename, "w")
      
      bite_code_file.write(JSON.dump(bite))
      bite_code_file.close
      
      return true
    rescue Dog::CompilationError => error
      puts error
    rescue Dog::ParseError => error
      puts error
    rescue Exception => error
      puts "Error: An unknown compilation error occured: "
      puts
      puts error
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
      Dog::Runtime.run_file(args.first, parse_options(args))
    rescue Exception => e
      raise e
      puts e
    end
  end
end

class Debug < Command
  Command.register(self)
  
  def description
    "Compile and execute a dog program after clearing the database."
  end
  
  def usage
    super
    puts
    puts "Usage: dog debug [FILE.dog] [options]"
    puts
    puts "  Compile a Dog program and execute the resulting bite code. If this program has already been executed"
    puts "  previously, 'debug' will clear that database so the code is run from a 'clean slate'. This command "
    puts "  takes the same options as the 'run' command."
    puts
  end
  
  def run(args)
    bite_code_file = File.basename(args.first, '.dog') + '.bite'
    
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
      Dog::Runtime.run_file(bite_code_file, options)
    rescue Exception => e
      puts e
      raise e
    end
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
    puts "Usage: dog shell [options] [statement]"
    puts
    puts "  Starts a Dog shell with a current application. You can optionally pass in a statement to"
    puts "  execute.  If you pass in a statement it will execute the statement and then immediately"
    puts "  return."
    puts
    puts "Options include: "
    puts "  -u url           # Specify the url of the Dog application to connect to with the shell"
    puts "  -d database      # Specify the database on the local machine to use. This overwrites -u."
    puts "  -t track_id      # Specify the track to use. Default: a new track will be created and returned"
    puts
  end

  def run(args)
    args ||= []
    
    url = nil
    database = nil
    track = nil
    statement = nil
    
    index = 0
    while index < args.length do
      arg = args[index]
      
      if arg == "-u" then
        index += 1
        database = nil
        url = args[index]
      elsif arg == "-d" then
        index += 1
        database = args[index]
        url = nil
      elsif arg == "-t" then
        index += 1
        track = args[index]
      else
        statement = arg
      end
      
      index += 1
    end
    
    if statement.nil? then
      puts "Hello? Yes, this is #{dog_version_string}. CTRL+C to quit."
      
      Signal.trap("INT") do
        puts
        puts "Bye!"
        exit()
      end

      loop do
        line = Readline::readline("> ")
        Readline::HISTORY.push(line)

        begin
          bark = Dog::Parser.parse(line, "dog_shell")
          bite = Dog::Compiler.compile(bark, "dog_shell")
          Dog::Runtime.initialize(bite, "dog_shell", {
            "config" => {
              "database" => "dog_shell"
            }
          })
          
          if track.nil? then
            track = ::Dog::Track.new("root")
          elsif track.kind_of? String
            track = ::Dog::Track.find_by_id(track)
          end

          track.stack = {}
          track.function_name = "root"
          track.current_node_path = []
          track.state = ::Dog::Track::STATE::RUNNING
          track.save

          Dog::Runtime.run_track(track)

          track.reload

          puts "=> " + track.read_stack(["nodes", 0]).ruby_value.inspect
        
        rescue Exception => e
          puts "Error: #{e.to_s}"
        end
      end
      
    else
      
      output = {}
      output["statement"] = statement
      
      begin
        bark = Dog::Parser.parse(statement, "dog_shell")
        bite = Dog::Compiler.compile(bark, "dog_shell")
        Dog::Runtime.initialize(bite, "dog_shell", {
          "config" => {
            "database" => "dog_shell"
          }
        })
          
        if track.nil? then
          track = ::Dog::Track.new("root")
        elsif track.kind_of? String
          track = ::Dog::Track.find_by_id(track)
        end
        
        track.stack = {}
        track.function_name = "root"
        track.current_node_path = []
        track.state = ::Dog::Track::STATE::RUNNING
        track.save
        
        Dog::Runtime.run_track(track)

        track.reload
        
        output["value"] = track.read_stack(["nodes",0]).ruby_value.inspect
      rescue Exception => e
        output["error"] = e.to_s
        output.delete("value")
      end
      
      output["track"] = track.id.to_s rescue nil
      puts JSON.pretty_generate(output)
      
    end
    
    
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

