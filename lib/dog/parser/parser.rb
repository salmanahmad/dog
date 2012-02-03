#
# Copyright 2011 by Salman Ahmad (salman@salmanahmad.com).
# All rights reserved.
#
# Permission is granted for use, copying, modification, distribution,
# and distribution of modified versions of this work as long as the
# above copyright notice is included.
#

module Dog
  
  class Parser
    
    Treetop.load(File.expand_path(File.join(File.dirname(__FILE__), 'grammar.treetop')))
    
    def self.parse(program)
      parser = self.class.new
      parser.parse(program)
    end
    
    def initialize
      @parser = DogParser.new
    end
    
    def parse(program)
      tree = @parser.parse(program)
      
      if(tree.nil?)
        raise "Parse error at offset: #{@parser.index}"
      end
      
      # clean up the tree by removing all nodes of default type 'SyntaxNode'
      self.clean_tree(tree)
      
      return tree
    end
    
    private
    
      def self.clean_tree(root_node)
        return if(root_node.elements.nil?)
        
        root_node.elements.delete_if do |node| 
          node.class == Treetop::Runtime::SyntaxNode
        end
        
        root_node.elements.each do |node| 
          self.clean_tree(node) 
        end
      end
      
  end
  
end