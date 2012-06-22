#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
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
          # Report errors
          # TODO - Abstract his into a CompilerError class and raise that. The actual printing should not be handled by the framework it should be handled by the client (aka the Dog executable, the test cases, etc.) I should never use 'puts' like this... change it, okay?
          puts "The following compilation errors occured:"
          puts
          
          for error in errors do
            puts error
            puts
          end
          
          if errors.size == 1 then 
            raise "Compilation Error: There was #{errors.size} error that took place."
          else 
            raise "Compilation Error: There were #{errors.size} errors that took place."
          end
          
        end
        
      end
      
      return bark
    end
    
  end
  
end