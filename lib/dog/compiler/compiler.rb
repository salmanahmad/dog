#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class CompilationError < RuntimeError
    attr_accessor :errors
  end
  
  class Compiler
    
    attr_accessor :bite
    attr_accessor :errors
    attr_accessor :current_filename
    
    
    def self.compile(bark, filename = "")
      compiler = self.new(filename)
      compiler.compile(bark)
    end
    
    def initialize(filename = "")
      self.current_filename = filename
      
      self.errors = []
      self.bite = {
        "version" => VERSION::STRING,
        "version_codename" => VERSION::CODENAME,
        "time" => Time.now,
        "main_filename" => self.current_filename,
        "signature" => "",
        "symbols" => {},
        "code" => {}
      }
    end
    
    def current_filename=(filename)
      if filename.strip.length == 0 then
        @current_filename = ""
      else
        @current_filename = File.expand_path(filename)
      end
    end
    
    def compile(bark)
      rule = Rules::Rule.new(self)
      rule.apply(bark)
      
      elements = bark.elements || []
      elements.each do |node|
        compile(node)
      end
      
      unless bark.parent
        
        bite["code"][self.current_filename] = bark.to_hash
        
        unless errors.empty?
          compilation_error = nil
          
          if errors.size == 1 then 
            failure_reason = "Compilation Error: There was #{errors.size} error that took place.\n\n#{errors.join("\n\n")}\n"
            compilation_error = CompilationError.new(failure_reason)
          else 
            failure_reason = "Compilation Error: There was #{errors.size} error that took place.\n\n#{errors.join("\n\n")}\n"
            compilation_error = CompilationError.new("Compilation Error: There were #{errors.size} errors that took place.\n\n#{errors.join("\n\n")}\n")
          end
          
          compilation_error.errors = errors
          raise compilation_error
        end
        
        if(self.current_filename == bite["main_filename"]) then
          bite["symbols"]["root"] = [bite["main_filename"]]
          bite["signature"] = Digest::SHA1.hexdigest(JSON.dump(bite))
        end
        
        return bite
      else
        return bark
      end
    end
    
  end
  
end

