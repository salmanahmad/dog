#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog::Rules
  
  class Rule
    
    class << self
      attr_accessor :registered_rules
      attr_accessor :errors
      
      def applicable_nodes
        rule = self.new
        rule.applicable_nodes
      end
      
      def apply(node)
        rule = self.new
        rule.apply(node)
      end
      
      def register(rule)
        self.registered_rules ||= []
        self.registered_rules << rule
      end
      
      def errors
        @errors ||= []
        @errors
      end
      
      def report_error_for_node(node, description)
        line = 1 + node.input.slice(0, node.interval.begin).count("\n")
        self.errors << "(line: #{line}) - #{description}."
      end
      
    end
    
    def applicable_nodes
      [::Dog::Nodes::Node]
    end
    
    def apply(node)
      for rule in self.class.registered_rules do
        for applicable_node in rule.applicable_nodes do
          if node.kind_of? applicable_node then
            rule.apply(node)
          end
        end
      end
    end
    
  end
  
end
