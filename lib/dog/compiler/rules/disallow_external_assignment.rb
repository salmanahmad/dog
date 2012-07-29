#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class DisallowExternalAssignment < Rule
    
    Rule.register(self)
    
    def applicable_nodes
      [
        ::Dog::Nodes::Assignment
      ]
    end
    
    def apply(node)
      if node.scope == "external" || node.scope == "internal" then
        self.compiler.report_error_for_node(node, "The assignment on line #{node.line} attempted to make an assignment out of scope. Dog does not allow sideffects outside of local functions. Consider using a collection to break this restriction while having safe and easy to test code.")
      end
    end
  end 
end
