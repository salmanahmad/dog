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
      
      def register(rule)
        self.registered_rules ||= []
        self.registered_rules << rule
      end
      
      def applicable_nodes
        rule = self.new
        rule.applicable_nodes
      end
    end
    
    attr_accessor :compiler
    
    def initialize(compiler = nil)
      self.compiler = compiler
    end
    
    def applicable_nodes
      [::Dog::Nodes::Node]
    end
    
    def apply(node)
      for rule in self.class.registered_rules do
        for applicable_node in rule.applicable_nodes do
          if node.kind_of? applicable_node then
            rule = rule.new(self.compiler)
            rule.apply(node)
          end
        end
      end
    end
    
    def report_error_for_node(node, description)
      self.compiler.errors << "(#{self.compiler.current_filename}:#{node.line}) - #{description}"
    end
    
  end
  
end
