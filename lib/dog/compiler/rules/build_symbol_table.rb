#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class BuildSymbolTable < Rule
    
    Rule.register(self)
    
    def applicable_nodes
      [::Dog::Nodes::DefineFunction]
    end
    
    def apply(node)
      path = node.path
      name = [self.name]
      
      parent = node
      while parent = parent.parent do
        if parent.class == ::Dog::Nodes::DefineFunction then
          name.unshift parent.name
        end
      end
      
      name = name.join(".")
      
      if self.compiler.symbols.include? name then
        report_error_for_node(node, "")
      else
        self.compiler.symbols[name] = path
      end
    end
    
  end 
end
