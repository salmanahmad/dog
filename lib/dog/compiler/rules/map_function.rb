#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class MapFunction < Rule
    
    class << self
      
      
      
    end
    
    Rule.register(self)
    
    def applicable_nodes
      [::Dog::Nodes::DefineFunction]
    end
    
    def apply(node)
      
    end
    
  end 
end
