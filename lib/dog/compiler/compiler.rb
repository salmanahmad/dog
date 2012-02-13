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
    
    def self.compile(collar)
      compiler = self.new
      compiler.compile(collar)
    end
    
    def initialize
      
    end
    
    def compile(collar)
      state = collar.compile
      return state
    end
    
  end
  
end