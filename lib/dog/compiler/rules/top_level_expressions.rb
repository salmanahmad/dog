#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class TopLevelExpressions < Rule
    
    Rule.register(self)
    
    def applicable_nodes
      [
        ::Dog::Nodes::Reply,
        ::Dog::Nodes::Return
      ]
    end
    
    def apply(node)
      parent = node
      while parent = parent.parent do
        if [::Dog::Nodes::On, ::Dog::Nodes::DefineFunction].include? parent.class then
          return
        end
      end
      
      report_error_for_node(node, "#{node.class.name.split("::").last} cannot appear in top level scope. They must appear inside a function.")
    end
    
  end 
end
