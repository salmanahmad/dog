#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class StandAloneCommands < Rule
    
    Rule.register(self)
    
    def applicable_nodes
      [
        ::Dog::Nodes::DefineVariable,
        ::Dog::Nodes::DefineFunction,
        ::Dog::Nodes::Listen,
        ::Dog::Nodes::Allow,
        ::Dog::Nodes::On,
        ::Dog::Nodes::Reply,
        ::Dog::Nodes::Return,
        ::Dog::Nodes::Config,
        ::Dog::Nodes::Import,
        ::Dog::Nodes::Print,
        ::Dog::Nodes::Inspect
      ]
    end
    
    def apply(node)
      if node.parent.class != ::Dog::Nodes::Statement
        Rule.report_error_for_node(node, "#{node.class.name.split("::").last} cannot be nested in other expressions")
      end
    end
    
  end 
end
