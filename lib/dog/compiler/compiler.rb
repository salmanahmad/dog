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
    
    def self.compile(bark)
      compiler = self.new
      compiler.compile(bark)
    end
    
    def compile(bark)
      Rules::Rule.apply(bark)
      
      elements = bark.elements || []
      elements.each do |node|
        compile(node)
      end
      
      unless bark.parent
        errors = Rules::Rule.errors
        unless errors.empty?
          compilation_error = nil
          
          if errors.size == 1 then 
            compilation_error = CompilationError.new("Compilation Error: There was #{errors.size} error that took place.\n\n#{errors.join("\n\n")}\n")
          else 
            compilation_error = CompilationError.new("Compilation Error: There were #{errors.size} errors that took place.\n\n#{errors.join("\n\n")}\n")
          end
          
          compilation_error.errors = errors
          raise compilation_error
        end
        
      end
      
      return bark
    end
    
  end
  
end