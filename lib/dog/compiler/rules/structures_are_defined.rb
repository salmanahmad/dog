#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class StructuresAreDefined < Rule
    
    Rule.register(self)
    
    def applicable_nodes
      [
        ::Dog::Nodes::Community,
        ::Dog::Nodes::Event,
        ::Dog::Nodes::Task,
        ::Dog::Nodes::Message
      ]
    end
    
    def apply(node)
      if node.parent.class != ::Dog::Nodes::DefineVariable then
        report_error_for_node(node, "#{node.class.name.split("::").last} must be defined")
      end
    end
    
  end 
end
