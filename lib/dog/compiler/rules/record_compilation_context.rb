#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class RecordCompilationContext < Rule
    
    Rule.register(self)
    
    def applicable_nodes
      [::Dog::Nodes::Node]
    end
    
    def apply(node)
      node.filename = self.compiler.filename
      node.line = 1 + node.input.slice(0, node.interval.begin).count("\n")
    end
    
  end 
end
