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
      [
        ::Dog::Nodes::FunctionDefinition,
        ::Dog::Nodes::OnEachDefinition,
        ::Dog::Nodes::StructureDefinition,
        ::Dog::Nodes::CollectionDefinition,
        ::Dog::Nodes::CommunityDefinition
      ]
    end
    
    def apply(node)
      path = node.path.clone.unshift(self.compiler.current_filename)
      name = [node.name]
      
      parent = node
      while parent = parent.parent do
        if parent.class == ::Dog::Nodes::FunctionDefinition || parent.class == ::Dog::Nodes::OnEachDefinition then
          name.unshift parent.name
        end
      end
      
      name = name.join(".")
      node.name = name
      
      if self.compiler.bite["symbols"].include? name then
        report_error_for_node(node, "The symbol named #{name} has been used twice. Symbols used to identify functions, events, task, and messages must be unique throughout the entire system.")
      else
        self.compiler.bite["symbols"][name] = path
      end
    end
    
  end 
end
